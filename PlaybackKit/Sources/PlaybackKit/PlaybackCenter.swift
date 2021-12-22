//
//  PlaybackCenter.swift
//  
//
//  Created by Lennart Fischer on 19.12.21.
//

import Foundation
import OSLog
import MediaPlayer
import Combine

public class PlaybackCenter {
    
    private let logger: Logger = Logger(.default)
    
    private let onPlay = PassthroughSubject<Void, Never>()
    
    public init() {
        
    }
    
    public func start() {
        
    }
    
}
