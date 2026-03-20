//
//  LegacyEventService.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import ModernNetworking
import Cache
import Core
import OSLog

public protocol LegacyEventService {
    
    func loadEvents() async throws -> [Event]
    
    func loadEventsFromNetwork() async throws -> [Event]
    
    func loadEventsFromPersistence() async throws -> [Event]
    
    func loadStream() async throws -> StreamConfig
    
    func invalidateCache()
    
    func show(eventID: Event.ID) async throws -> Event
    
}

public extension Notification.Name {
    
    static let updatedEvents = Notification.Name("updateEvents")
    
}