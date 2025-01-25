//
//  LegacyEventService.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import ModernNetworking
import Combine
import Cache
import Core
import OSLog

public protocol LegacyEventService {
    
    func loadEvents() -> AnyPublisher<[Event], Error>
    
    func loadEventsFromNetwork() -> AnyPublisher<[Event], Error>
    
    func loadEventsFromPersistence() -> AnyPublisher<[Event], Error>
    
    func loadStream() -> AnyPublisher<StreamConfig, Error>
    
    func invalidateCache()
    
    func show(eventID: Event.ID) -> AnyPublisher<Event, Error>
    
}

public extension Notification.Name {
    
    static let updatedEvents = Notification.Name("updateEvents")
    
}
