//
//  Message.swift
//  
//
//  Created by Yura on 11/20/22.
//

import Foundation

protocol Payload {
    var source: String { get }
    var data: Data { get }
}
