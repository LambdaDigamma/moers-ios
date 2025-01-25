//
//  LivestreamData.swift
//  
//
//  Created by Lennart Fischer on 04.05.21.
//

import Foundation

public struct LivestreamData: Equatable {
    
    public static func == (lhs: LivestreamData, rhs: LivestreamData) -> Bool {
        return lhs.streamConfig == rhs.streamConfig
            && lhs.events.map { $0.model.id } == rhs.events.map { $0.model.id }
    }
    
    
    public init(streamConfig: StreamConfig, events: [Event]) {
        self.streamConfig = streamConfig
        self.events = events.map { EventViewModel(event: $0) }
    }
    
    public var streamConfig: StreamConfig
    public var events: [EventViewModel<Event>]
    
    public var activeEvent: EventViewModel<Event>? {
        return events.filter({ $0.isActive }).first
    }
    
}
