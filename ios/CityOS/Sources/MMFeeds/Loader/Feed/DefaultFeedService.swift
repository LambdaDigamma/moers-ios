//
//  DefaultFeedService.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation
import Combine
import ModernNetworking
import Cache

public class DefaultFeedService: FeedService {
    
    private let loader: HTTPLoader
    private let cache: Storage<String, Feed>
    
    public init(_ loader: HTTPLoader = URLSessionLoader(), _ cache: Storage<String, Feed>) {
        self.loader = loader
        self.cache = cache
    }
    
    public func loadFeedFromNetwork(feedID: Feed.ID, perPage: Int = 10) -> AnyPublisher<Feed, Error> {
        
        let request = HTTPRequest(path: Endpoint.show(feedID: feedID).path())
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
        .compactMap { $0.body }
        .decode(type: Resource<Feed>.self, decoder: Feed.decoder)
        .map({
            //            self.cache.async.setObject($0, forKey: "events") { (result) in }
            return $0.data
        })
        .eraseToAnyPublisher()
        
    }
    
    public func loadPosts(for feedID: Feed.ID, page: Int = 1, perPage: Int = 10) -> AnyPublisher<ResourceCollection<Post>, Error> {
        
        var request = HTTPRequest(path: Endpoint.showPosts(feedID: feedID).path())
        
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(perPage)),
            URLQueryItem(name: "page[number]", value: String(page))
        ]
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
        .compactMap { $0.body }
        .decode(type: ResourceCollection<Post>.self, decoder: Feed.decoder)
//        .map({
            //            self.cache.async.setObject($0, forKey: "events") { (result) in }
//            return $0.data
//        })
        .eraseToAnyPublisher()
        
    }
    
    public func loadPosts(for feedID: Feed.ID, page: Int = 1, perPage: Int = 10) async throws -> ResourceCollection<Post> {
        
        var request = HTTPRequest(path: Endpoint.showPosts(feedID: feedID).path())
        
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(perPage)),
            URLQueryItem(name: "page[number]", value: String(page))
        ]
        
        let result = await loader.load(request)
        
        let posts = try await result.decoding(ResourceCollection<Post>.self)
        
        return posts
        
    }
    
    public func loadFeed(page: Int = 1) -> AnyPublisher<Feed, Error> {
        
        var request = HTTPRequest(path: Endpoint.index.path())
        
        request.queryItems = [URLQueryItem(name: "page", value: String(page))]
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
        .compactMap { $0.body }
        .decode(type: Resource<Feed>.self, decoder: Feed.decoder)
        .map({
            //            self.cache.async.setObject($0, forKey: "events") { (result) in }
            return $0.data
        })
        .eraseToAnyPublisher()
        
    }
    
    
}

extension DefaultFeedService {
    
    public enum Endpoint {
        case index
        case show(feedID: Feed.ID)
        case showPosts(feedID: Feed.ID)
        
        func path() -> String {
            switch self {
                case .index:
                    return "feeds"
                case .show(let id):
                    return "feeds/\(id)"
                case .showPosts(let id):
                    return "feeds/\(id)/posts"
            }
        }
    }
    
    public enum CachingKeys: String {
        case feeds = "feeds"
    }
    
}
