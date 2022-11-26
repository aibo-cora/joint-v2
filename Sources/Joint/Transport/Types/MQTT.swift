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
            session?.publishData(message.data, onTopic: message.source, retain: false, qos: self.qos, publishHandler: { error in
                if let error {
                    self.error.send(.publishing(message.source, error, .critial))
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
        
        // MARK: - MQTTSessionDelegate
        
        func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
            NSLog("Event=\(eventCode.rawValue) coming from \(String(describing: transport.host)):\(transport.port)")
            
            switch eventCode {
            case .connected:
                break
            case .connectionClosed:
                self.error.send(.connecting("MQTT Client: Connection Closed", .critial))
            case .connectionClosedByBroker:
                self.error.send(.connecting("MQTT Client: Connection Closed by Broker", .critial))
            case .connectionError:
                self.error.send(.connecting("MQTT Client: Connection Error", .critial))
            case .connectionRefused:
                self.error.send(.connecting("MQTT Client: Connection Refused", .critial))
            case .protocolError:
                self.error.send(.connecting("MQTT Client: Protocol Error", .critial))
            default:
                break
            }
        }
        
        func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
            receiving.send(Message(source: topic, data: data))
        }
    }
}
