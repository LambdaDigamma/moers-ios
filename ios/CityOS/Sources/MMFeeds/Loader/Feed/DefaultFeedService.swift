//
//  DefaultFeedService.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation
import Core
import ModernNetworking
import Cache

public class DefaultFeedService: FeedService {
    
    private let client: any HTTPClient
    private let cache: Storage<String, Feed>
    
    public init(client: any HTTPClient, _ cache: Storage<String, Feed>) {
        self.client = client
        self.cache = cache
    }

    @MainActor
    public convenience init(_ loader: HTTPLoader = URLSessionLoader(), _ cache: Storage<String, Feed>) {
        self.init(client: HTTPLoaderClient(loader: loader), cache)
    }
    
    public func loadFeedFromNetwork(feedID: Feed.ID, perPage: Int = 10) async throws -> Feed {
        
        let request = HTTPRequest(path: Endpoint.show(feedID: feedID).path())
        
        let result = await client.load(request)
        let resource = try await result.decoding(Resource<Feed>.self, using: Feed.decoder)
        
        return resource.data
        
    }
    
    public func loadPosts(for feedID: Feed.ID, page: Int = 1, perPage: Int = 10) async throws -> ResourceCollection<Post> {
        
        var request = HTTPRequest(path: Endpoint.showPosts(feedID: feedID).path())
        
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(perPage)),
            URLQueryItem(name: "page[number]", value: String(page))
        ]
        
        let result = await client.load(request)
        
        let posts = try await result.decoding(ResourceCollection<Post>.self, using: Feed.decoder)
        
        return posts
        
    }
    
    public func loadFeed(page: Int = 1) async throws -> Feed {
        
        var request = HTTPRequest(path: Endpoint.index.path())
        
        request.queryItems = [URLQueryItem(name: "page", value: String(page))]
        
        let result = await client.load(request)
        
        let resource = try await result.decoding(Resource<Feed>.self, using: Feed.decoder)
        
        return resource.data
        
    }
    

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
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
