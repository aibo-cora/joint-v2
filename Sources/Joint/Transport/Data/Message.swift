//
//  Message.swift
//  
//
//  Created by Yura on 11/20/22.
//

import Foundation

/// Message description.
public protocol Payload {
    var channel: String { get }
    var payload: Data { get }
}

/// Intended recipient and contents of a message being transported.
public struct Message: Payload {
    public init(for channel: String, carrying payload: Data) {
        self.channel = channel
        self.payload = payload
    }
    
    public var channel: String
    public var payload: Data
}
