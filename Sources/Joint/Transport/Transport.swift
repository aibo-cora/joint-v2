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
    func publish(message: Message)
    func open(channels: [String])
    func close(channels: [String])
    
    var receiving: PassthroughSubject<Message, Never> { get }
    var error: CurrentValueSubject<TransportError, Never> { get }
}

/// Data transport methods.
public enum TransportMethod { case MQTT(Server) }

public enum TransportError: Error {
    case none
    case publishing(String, Error, SeverityLevel)
    case opening(String, Error, SeverityLevel)
    case closing(String, Error, SeverityLevel)
    case connecting(String, SeverityLevel)
    
    public enum SeverityLevel {
        case discardable, warning, critial
    }
}

/// The source and contents of a message being transported.
public struct Message: Payload {
    var source: String
    var data: Data
}

final class Transport: ObservableObject {
    @Published var receiving: Message = .init(source: "", data: Data())
    @Published var error: TransportError = .none
    
    private var subscriptions = [AnyCancellable]()
    /// Transport layer.
    /// - Parameter method: Choose how to transport data.
    init(using method: TransportMethod) {
        switch method {
        case .MQTT (let server):
            self.layer = MQTT(server: server)
        }
        
        layer.error
            .dropFirst()
            .sink { error in
                self.error = error
            }
            .store(in: &subscriptions)
        layer.receiving
            .dropFirst()
            .sink { message in
                self.receiving = message
            }
            .store(in: &subscriptions)
    }
    
    /// Connect to the server.
    func connect() {
        layer.connect()
    }
    
    func publish(message: Message) {
        layer.publish(message: message)
    }
    
    /// Open and close links.
    func updateLinks(subscribeTo: [String], unsubscribeFrom: [String]) {
        self.layer.open(channels: subscribeTo)
        self.layer.close(channels: unsubscribeFrom)
    }
    
    let layer: any TransportLayer
}
