//
//  Transport.swift
//  
//
//  Created by Yura on 11/20/22.
//

import Foundation
import Combine

protocol TransportLayer: ObservableObject {
    func connect()
    func publish(message: Transport.Message)
    
    var incoming: PassthroughSubject<Transport.Message, Never> { get }
}

public struct Transport {
    public enum Methods { case MQTT(Server) }
    
    public init(method: Methods) {
        switch method {
        case .MQTT (let server):
            self.layer = MQTT(server: server)
        }
    }
    
    /// Connect to the server.
    func connect() {
        layer.connect()
    }
    
    func publish(message: Transport.Message) {
        layer.publish(message: message)
    }
    
    /// Open and close links.
    func updateLinks() {
        
    }
    
    let layer: any TransportLayer
}
