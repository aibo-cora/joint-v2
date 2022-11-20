//
//  Broker.swift
//  
//
//  Created by Yura on 11/20/22.
//

import Foundation

public protocol Endpoint {
    var ip: String { get }
    var port: UInt32 { get }
}

public protocol Credentials {
    var username: String { get }
    var password: String { get }
}

public protocol Server: Endpoint, Credentials {
    var secure: Bool { get }
}
