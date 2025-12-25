//
//  StaticEventService.swift
//  
//
//  Created by Lennart Fischer on 13.04.23.
//

import Foundation
import ModernNetworking

public class StaticEventService: EventService {
    
    private let events: Result<[Event], Error>
    
    public init(events: Result<[Event], Error>) {
        self.events = events
    }
    
    public func index(cacheMode: CacheMode, withPages: Bool) async throws -> ResourceCollection<Event> {
        
        switch events {
            case .success(let success):
                return ResourceCollection(data: success, links: .init(), meta: .init())
            case .failure(let failure):
                throw failure
        }
        
    }
    
    public func show(event eventID: Event.ID, cacheMode: CacheMode) async throws -> Resource<Event> {
        
        return Resource(data: .stub(withID: 1))
        
    }
    
}
