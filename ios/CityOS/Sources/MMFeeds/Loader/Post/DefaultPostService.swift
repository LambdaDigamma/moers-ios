//
//  DefaultPostService.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import ModernNetworking
import Cache

public class DefaultPostService: PostService {
    
    nonisolated(unsafe) private let loader: HTTPLoader
    
    public init(_ loader: HTTPLoader = URLSessionLoader()) {
        self.loader = loader
    }
    
    public func index(for feedID: Feed.ID, page: Int = 1, perPage: Int = 10, cacheMode: CacheMode) async throws -> ResourceCollection<Post> {
        
        var request = HTTPRequest(path: Endpoint.index(feedID: feedID).path())
        
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(perPage)),
            URLQueryItem(name: "page[number]", value: String(page))
        ]
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        
        let posts = try await result.decoding(ResourceCollection<Post>.self)
        
        return posts
        
    }
    
    public func show(for postID: Post.ID, cacheMode: CacheMode) async throws -> Resource<Post> {
        
        var request = Self.showRequest(postID: postID)
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        
        let post = try await result.decoding(Resource<Post>.self)
        
        return post
        
    }
    
    internal static func indexRequest(feedID: Feed.ID, page: Int, perPage: Int) -> HTTPRequest {
        
        var request = HTTPRequest(path: Endpoint.index(feedID: feedID).path())
        
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(perPage)),
            URLQueryItem(name: "page[number]", value: String(page))
        ]
        
        return request
        
    }
    
    internal static func showRequest(postID: Post.ID) -> HTTPRequest {
        
        var request = HTTPRequest(path: Endpoint.show(postID: postID).path())
        
        request.queryItems = []
        
        return request
        
    }
    
}

extension DefaultPostService {
    
    public enum Endpoint {
        case index(feedID: Feed.ID)
        case show(postID: Post.ID)
        
        func path() -> String {
            switch self {
                case .show(let id):
                    return "posts/\(id)"
                case .index(let id):
                    return "feeds/\(id)/posts"
            }
        }
    }
    
}