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
        var incoming = PassthroughSubject<Transport.Message, Never>()
        
        private let transport = MQTTCFSocketTransport()
        private let session = MQTTSession()
        
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
        
        func connect() {
            session?.connect()
        }
        
        func publish(message: Message) {
            session?.publishData(message.data, onTopic: message.source, retain: false, qos: .atMostOnce, publishHandler: { error in
                
            })
        }
        
        // MARK: - MQTTSessionDelegate
        func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
            NSLog("Event=\(eventCode.rawValue) coming from \(String(describing: transport.host)):\(transport.port)")
            
            switch eventCode {
            case .connected:
                break
            default:
                break
            }
        }
        
        func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
            incoming.send(Message(source: topic, data: data))
        }
    }
}
