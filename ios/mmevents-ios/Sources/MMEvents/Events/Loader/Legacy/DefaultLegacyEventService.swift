//
//  DefaultEventService.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation
import ModernNetworking
import Combine
import Cache
import Core
import OSLog

public class DefaultLegacyEventService: LegacyEventService {
    
    private let loader: HTTPLoader
    private let cache: Storage<String, [Event]>
    private let logger: Logger = .init(.coreApi)
    
    private var lastUpdate: LastUpdate = .init(key: "all_events")
    
    public init(_ loader: HTTPLoader = URLSessionLoader(), _ cache: Storage<String, [Event]>) {
        self.loader = loader
        self.cache = cache
    }
    
    public func loadEvents() -> AnyPublisher<[Event], Error> {
        
        if lastUpdate.shouldReload(ttl: .minutes(5)) {
            logger.info("Should reload all events")
            return loadEventsFromNetwork()
        } else {
            logger.info("Do not reload all events")
            return loadEventsFromPersistence()
        }
        
    }
    
    public func loadEventsFromNetwork() -> AnyPublisher<[Event], Error> {
        
        var request = HTTPRequest(path: Endpoint.index.path())
        
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(180)),
        ]
        
        print("headers: ")
        print(request.headers)
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
        .compactMap { $0.body }
        .decode(type: ResourceCollection<Event>.self, decoder: Event.decoder)
        .map({
            $0.data.chronologically()
        })
        .map({
            self.cache.async.setObject($0, forKey: CachingKeys.events.rawValue) { (result) in }
            self.lastUpdate.setNow()
            return $0
        })
        .eraseToAnyPublisher()
        
    }
    
    public func loadEventsFromPersistence() -> AnyPublisher<[Event], Error> {
        
        return Deferred {
            Future { promise in
                self.cache.async.object(forKey: CachingKeys.events.rawValue) { (result: Result<[Event], Error>) in
                    switch result {
                        case .success(let success):
                            promise(.success(success))
                            break
                        case .failure(let failure):
                            promise(.failure(failure))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    public func show(eventID: Event.ID) -> AnyPublisher<Event, Error> {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/events/\(eventID)"
        )
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .compactMap { $0.body }
        .decode(type: Resource<Event>.self, decoder: Event.decoder)
        .map({
            return $0.data
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    public func invalidateCache() {
        lastUpdate.reset()
        try? cache.removeAll()
    }
    
    public func loadStream() -> AnyPublisher<StreamConfig, Error> {
        
        let request = HTTPRequest(path: Endpoint.stream.path())
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
        .compactMap { $0.body }
        .decode(type: StreamConfig.self, decoder: StreamConfig.decoder)
        .eraseToAnyPublisher()
        
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
