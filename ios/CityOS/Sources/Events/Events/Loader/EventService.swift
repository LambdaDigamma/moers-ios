//
//  EventService.swift
//  
//
//  Created by Lennart Fischer on 13.04.23.
//

import Foundation
import ModernNetworking

public protocol EventService {
    
    func index(cacheMode: CacheMode, withPages: Bool) async throws -> ResourceCollection<Event>

    func index(
        cacheMode: CacheMode,
        withPages: Bool,
        onPage: @escaping @MainActor @Sendable ([Event]) -> Void
    ) async throws -> ResourceCollection<Event>
    
    func show(event eventID: Event.ID, cacheMode: CacheMode) async throws -> Resource<Event>
    
}

public extension EventService {
    func index(
        cacheMode: CacheMode,
        withPages: Bool,
        onPage: @escaping @MainActor @Sendable ([Event]) -> Void
    ) async throws -> ResourceCollection<Event> {
        let response = try await index(cacheMode: cacheMode, withPages: withPages)
        try Task.checkCancellation()
        onPage(response.data)
        return response
    }
}
