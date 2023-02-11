//
//  MQTT.swift
//  
//
//  Created by Yura on 11/20/22.
//

import Foundation
import MQTTClient
import Combine

extension Transport {
    final class MQTT: NSObject, TransportLayer, MQTTSessionDelegate {
        let error = CurrentValueSubject<TransportError, Never>(.none)
        let receiving = PassthroughSubject<Message, Never>()
        let status = PassthroughSubject<TransportStatus, Never>()
        
        private let transport = MQTTCFSocketTransport()
        private let session = MQTTSession()
        private let qos: MQTTQosLevel = .atMostOnce
        
        init(server: Server) {
            super.init()
            
            MQTTLog.setLogLevel(.off)
            
            transport.host = server.ip
            transport.port = server.port
            transport.tls = server.secure
            
            session?.cleanSessionFlag = true
            session?.transport = transport
            session?.delegate = self
            session?.userName = server.username
            session?.password = server.password
        }
        
        // MARK: - TransportLayer
        
        func connect() {
            session?.connect()
        }
        
        func publish(message: Message) {
            session?.publishData(message.payload, onTopic: message.channel, retain: false, qos: self.qos, publishHandler: { error in
                if let error {
                    self.error.send(.publishing(message.channel, error, .critial))
                }
            })
        }
        
        func open(channels: [String]) {
            channels.forEach { channel in
                session?.subscribe(toTopic: channel, at: self.qos, subscribeHandler: { error, number in
                    if let error {
                        self.error.send(.opening(channel, error, .warning))
                    }
                })
            }
        }
        
        func close(channels: [String]) {
            channels.forEach { channel in
                session?.unsubscribeTopic(channel, unsubscribeHandler: { error in
                    if let error {
                        self.error.send(.closing(channel, error, .warning))
                    }
                })
            }
        }
        
        func disconnect() {
            session?.close(disconnectHandler: { error in
                if let error {
                    self.error.send(.disconnecting(error, .warning))
                }
                self.status.send(.disconnected)
            })
        }
        
        // MARK: - MQTTSessionDelegate
        
        func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
            NSLog("Event=\(eventCode.rawValue) coming from \(String(describing: transport.host)):\(transport.port)")
            
            let error: TransportError
            switch eventCode {
            case .connected:
                self.error.send(.none)
                self.status.send(.connected)
                return
            case .connectionClosed:
                error = .connecting("MQTT Client: Connection Closed", .critial)
            case .connectionClosedByBroker:
                error = .connecting("MQTT Client: Connection Closed by Broker", .critial)
            case .connectionError:
                error = .connecting("MQTT Client: Connection Error", .critial)
            case .connectionRefused:
                error = .connecting("MQTT Client: Connection Refused", .critial)
            case .protocolError:
                error = .connecting("MQTT Client: Protocol Error", .critial)
            default:
                return
            }
            self.status.send(.failed)
            self.error.send(error)
        }
        
        func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
            receiving.send(Message(for: topic, carrying: data))
        }
    }
}
