//
//  TimetableTransmitter.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

import Foundation
import Combine
import OSLog

public class TimetableTransmitter: ObservableObject {
    
    public let showEvent: PassthroughSubject<Event.ID, Never>
    private let logger: Logger

    public init() {
        self.showEvent = PassthroughSubject<Event.ID, Never>()
        self.logger = Logger(
            subsystem: "io.inventas.tfdoors.ios.backend",
            category: "TimetableTransmitter"
        )
    }
    
    public func dispatchShowEvent(_ id: Event.ID) {
        showEvent.send(id)
    }

    
}
