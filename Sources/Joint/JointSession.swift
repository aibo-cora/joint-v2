//
//  JointSession.swift
//  
//
//  Created by Yura on 11/26/22.
//

import Foundation
import JointCore
import Combine
import AVFoundation

public final class JointSession: ObservableObject {
    /// `AVCaptureSession` video sample buffer.
    @Published public var sampleBuffer: CMSampleBuffer?
    
    @Published public var outgoing: Message?
    @Published public var incoming: Message?
    
    @Published public var transportError: TransportError = .none
    
    private let transport: Transport
    private let bond: Bond
    
    private var subscriptions = [AnyCancellable]()
    
    public init(datasource source: String, using method: TransportMethod, video: AVCaptureVideoDataOutput, audio: PassthroughSubject<AVAudioPCMBuffer, Never>) {
        transport = Transport(using: method)
        bond = Bond(cameraOutput: video, audioPipeline: audio)
        
        bond.$data
            .sink { data in
                let message = Message(source: source, data: data)
                
                self.transport.publish(message: message)
                self.outgoing = message
            }
            .store(in: &subscriptions)
        bond.$sampleBuffer
            .sink { buffer in
                self.sampleBuffer = buffer
            }
            .store(in: &subscriptions)
        
        transport.$error
            .sink { error in
                self.transportError = error
            }
            .store(in: &subscriptions)
        transport.$receiving
            .sink { message in
                self.incoming = message
            }
            .store(in: &subscriptions)
    }
    // MARK: Transport
    /// Connect to the server.
    public func connect() {
        transport.connect()
    }
    
    /// Update channel list.
    /// - Parameters:
    ///   - subscribeTo: Channels to subscribe to.
    ///   - unsubscribeFrom: Channels to unsubscribe from.
    public func updateLinks(subscribeTo: [String], unsubscribeFrom: [String]) {
        transport.updateLinks(subscribeTo: subscribeTo, unsubscribeFrom: unsubscribeFrom)
    }
    
    /// Disconnect from the server and close the session.
    public func disconnect() {
        transport.disconnect()
    }
    // MARK: Bond
    /// Start capturing video and audio buffers to be transported.
    public func start() {
        bond.start()
    }
    
    /// Stop capturing buffers.
    public func stop() {
        bond.stop()
    }
}
