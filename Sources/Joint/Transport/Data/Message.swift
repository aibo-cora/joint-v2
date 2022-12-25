//
//  Message.swift
//  
//
//  Created by Yura on 11/20/22.
//

import Foundation

/// Message description.
public protocol Payload {
    var source: String { get }
    var data: Data { get }
}

/// The source and contents of a message being transported.
public struct Message: Payload {
    public var source: String
    public var data: Data
}
