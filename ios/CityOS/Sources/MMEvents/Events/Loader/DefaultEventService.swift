//
//  DefaultEventService.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation
import ModernNetworking

public class DefaultEventService: EventService {
    
    nonisolated(unsafe) private let loader: HTTPLoader
    
    public init(_ loader: HTTPLoader = URLSessionLoader()) {
        self.loader = loader
    }
    
    public func index(cacheMode: CacheMode, withPages: Bool = false) async throws -> ResourceCollection<Event> {
        
        var request = HTTPRequest(path: withPages ? Endpoint.downloadContent.path() : Endpoint.index.path())
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        
        let events = try await result
            .decoding(EventResourceCollection.self, using: Event.decoder)
            .resourceCollection
        
        return events
        
    }
    
    public func show(event eventID: Event.ID, cacheMode: CacheMode) async throws -> Resource<Event> {
        
        var request = HTTPRequest(path: Endpoint.show(event: eventID).path())
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        
        let events = try await result
            .decoding(EventResource.self, using: Event.decoder)
            .resource
        
        return events
        
    }
    
}

private struct EventResource: Model {

    let data: Event

    enum CodingKeys: String, CodingKey {
        case data
    }

    var resource: Resource<Event> {
        Resource(data: data)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.data) {
            self.data = try container.decode(Event.self, forKey: .data)
        } else {
            self.data = try Event(from: decoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }

    static var decoder: JSONDecoder { Event.decoder }
}

private struct EventResourceCollection: Model {

    let data: [Event]
    let links: ResourceLinks
    let meta: ResourceMeta

    enum CodingKeys: String, CodingKey {
        case data
        case links
        case meta
    }

    var resourceCollection: ResourceCollection<Event> {
        ResourceCollection(data: data, links: links, meta: meta)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.data = try container.decode([Event].self, forKey: .data)
        self.links = (try? container.decode(ResourceLinks.self, forKey: .links)) ?? ResourceLinks()

        if let resourceMeta = try? container.decode(ResourceMeta.self, forKey: .meta) {
            self.meta = resourceMeta
        } else {
            self.meta = try container.decode(FlexibleResourceMeta.self, forKey: .meta).resourceMeta
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(links, forKey: .links)
        try container.encode(meta, forKey: .meta)
    }

    static var decoder: JSONDecoder { Event.decoder }
}

private struct FlexibleResourceMeta: Decodable {

    let currentPage: Int?
    let from: Int?
    let lastPage: Int?
    let path: String?
    let perPage: Int?
    let to: Int?
    let total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case path
        case perPage = "per_page"
        case to
        case total
    }

    var resourceMeta: ResourceMeta {
        ResourceMeta(
            currentPage: currentPage,
            from: from,
            lastPage: lastPage ?? 1,
            links: [],
            path: path ?? "",
            perPage: perPage ?? 10,
            to: to,
            total: total
        )
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
                    return "content"
            }
        }
    }
    
    public enum CachingKeys: String {
        case events = "events"
    }
    
}
