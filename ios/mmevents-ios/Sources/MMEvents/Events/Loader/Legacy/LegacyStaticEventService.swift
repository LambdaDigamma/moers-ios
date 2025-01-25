//
//  LegacyStaticEventService.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation
import Combine

public class LegacyStaticEventService: LegacyEventService {
    
    public init() {}
    
    public func loadEvents() -> AnyPublisher<[Event], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadEventsFromNetwork() -> AnyPublisher<[Event], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadEventsFromPersistence() -> AnyPublisher<[Event], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadStream() -> AnyPublisher<StreamConfig, Error> {
        return Just(StreamConfig())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func invalidateCache() {
        
    }
    
    public func show(eventID: Event.ID) -> AnyPublisher<Event, Error> {
        return Just(Event.stub(withID: 1).setting(\.name, to: "Amaro Freitas (BR) + Introduction by DJ Tudo (BR)"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}
