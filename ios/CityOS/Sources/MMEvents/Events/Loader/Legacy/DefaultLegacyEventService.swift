//
//  DefaultEventService.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation
import ModernNetworking
import Cache
import Core
import OSLog

public class DefaultLegacyEventService: LegacyEventService {
    
    nonisolated(unsafe) private let loader: HTTPLoader
    private let cache: Storage<String, [Event]>
    private let logger: Logger = .init(.coreApi)
    
    private var lastUpdate: LastUpdate = .init(key: "all_events")
    
    public init(_ loader: HTTPLoader = URLSessionLoader(), _ cache: Storage<String, [Event]>) {
        self.loader = loader
        self.cache = cache
    }
    
    public func loadEvents() async throws -> [Event] {
        
        if lastUpdate.shouldReload(ttl: .minutes(5)) {
            logger.info("Should reload all events")
            return try await loadEventsFromNetwork()
        } else {
            logger.info("Do not reload all events")
            return try await loadEventsFromPersistence()
        }
        
    }
    
    public func loadEventsFromNetwork() async throws -> [Event] {
        
        var request = HTTPRequest(path: Endpoint.index.path())
        
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(180)),
        ]
        
        print("headers: ")
        print(request.headers)
        
        let result = await loader.load(request)
        
        let resource = try await result.decoding(ResourceCollection<Event>.self, using: Event.decoder)
        
        let events = resource.data.chronologically()
        
        self.cache.async.setObject(events, forKey: CachingKeys.events.rawValue) { (result) in }
        self.lastUpdate.setNow()
        
        return events
        
    }
    
    public func loadEventsFromPersistence() async throws -> [Event] {
        
        return try await withCheckedThrowingContinuation { continuation in
            self.cache.async.object(forKey: CachingKeys.events.rawValue) { (result: Result<[Event], Error>) in
                switch result {
                    case .success(let success):
                        continuation.resume(returning: success)
                    case .failure(let failure):
                        continuation.resume(throwing: failure)
                }
            }
        }
        
    }
    
    public func show(eventID: Event.ID) async throws -> Event {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/festival/events/\(eventID)"
        )
        
        let result = await loader.load(request)
        
        let resource = try await result.decoding(Resource<Event>.self, using: Event.decoder)
        
        return resource.data
        
    }
    
    public func invalidateCache() {
        lastUpdate.reset()
        try? cache.removeAll()
    }
    
    public func loadStream() async throws -> StreamConfig {
        
        let request = HTTPRequest(path: Endpoint.stream.path())
        
        let result = await loader.load(request)
        
        return try await result.decoding(StreamConfig.self, using: StreamConfig.decoder)
        
    }
    
}

extension DefaultLegacyEventService {
    
    public enum Endpoint {
        case index
        case show(event: Event)
        case stream
        
        func path() -> String {
            switch self {
                case .index:
                    return "events"
                case .show(let event):
                    return "events/\(event.id)"
                case .stream:
                    return "stream"
            }
        }
    }
    
    public enum CachingKeys: String {
        case events = "events"
    }
    
}
