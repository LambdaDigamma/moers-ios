//
//  ActionTransmitter.swift
//  
//
//  Created by Lennart Fischer on 25.11.21.
//

import Foundation
import Combine
import OSLog

/// Transmits actions from page view blocks to the context
public class ActionTransmitter: ObservableObject {
    
    public let showURL: PassthroughSubject<URL, Never>
    private let logger: Logger
    
    public init() {
        self.showURL = PassthroughSubject<URL, Never>()
        self.logger = Logger(.default)
    }
    
    public func dispatchOpenURL(_ url: URL) {
        logger.info("Dispatching open url: \(url.absoluteString, privacy: .public)")
        showURL.send(url)
    }
    
}
