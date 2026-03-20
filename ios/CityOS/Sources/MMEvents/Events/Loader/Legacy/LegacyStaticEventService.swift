//
//  LegacyStaticEventService.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation

public class LegacyStaticEventService: LegacyEventService {
    
    public init() {}
    
    public func loadEvents() async throws -> [Event] {
        return []
    }
    
    public func loadEventsFromNetwork() async throws -> [Event] {
        return []
    }
    
    public func loadEventsFromPersistence() async throws -> [Event] {
        return []
    }
    
    public func loadStream() async throws -> StreamConfig {
        return StreamConfig()
    }
    
    public func invalidateCache() {
        
    }
    
    public func show(eventID: Event.ID) async throws -> Event {
        return Event.stub(withID: 1).setting(\.name, to: "Amaro Freitas (BR) + Introduction by DJ Tudo (BR)")
    }
    
}