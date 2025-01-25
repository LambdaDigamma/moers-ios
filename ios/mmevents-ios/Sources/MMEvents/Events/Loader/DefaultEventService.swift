//
//  DefaultEventService.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation
import ModernNetworking

public class DefaultEventService: EventService {
    
    private let loader: HTTPLoader
    
    public init(_ loader: HTTPLoader = URLSessionLoader()) {
        self.loader = loader
    }
    
    public func index(cacheMode: CacheMode, withPages: Bool = false) async throws -> ResourceCollection<Event> {
        
        var request = HTTPRequest(path: withPages ? Endpoint.downloadContent.path() : Endpoint.index.path())
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        
        let events = try await result.decoding(ResourceCollection<Event>.self, using: Event.decoder)
        
        return events
        
    }
    
    public func show(event eventID: Event.ID, cacheMode: CacheMode) async throws -> Resource<Event> {
        
        var request = HTTPRequest(path: Endpoint.show(event: eventID).path())
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        
        let events = try await result.decoding(Resource<Event>.self, using: Event.decoder)
        
        return events
        
    }
    
}

extension DefaultEventService {
    
    public enum Endpoint {
        case index
        case show(event: Event.ID)
        case downloadContent
        
        func path() -> String {
            switch self {
                case .index:
                    return "events"
                case .show(let eventID):
                    return "events/\(eventID)"
                case .downloadContent:
                    return "festival/content"
            }
        }
    }
    
    public enum CachingKeys: String {
        case events = "events"
    }
    
}
