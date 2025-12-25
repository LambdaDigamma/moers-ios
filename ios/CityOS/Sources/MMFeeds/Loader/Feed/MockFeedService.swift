//
//  MockFeedService.swift
//  
//
//  Created by Lennart Fischer on 06.02.21.
//

import Foundation
import Combine
import ModernNetworking
import Core

public class MockFeedService: FeedService {
    
    private let posts: [Post]
    
    public init(posts: [Post] = Array.stub(withCount: 20)) {
        self.posts = posts
    }
    
    public func loadFeedFromNetwork(feedID: Feed.ID, perPage: Int) -> AnyPublisher<Feed, Error> {
        
        let feed = Feed.stub(withID: feedID)
            .setting(\.name, to: "Main Feed")
            .setting(\.posts, to: posts)

        return Just(feed)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadPosts(for feedID: Feed.ID, page: Int, perPage: Int) -> AnyPublisher<ResourceCollection<Post>, Error> {
        
        let resourceCollection = ResourceCollection<Post>(
            data: Array<Post>.stub(withCount: 10, startingAt: 10),
            links: ResourceLinks(),
            meta: ResourceMeta()
        )
        
        return Just(resourceCollection)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadPosts(for feedID: Feed.ID, page: Int, perPage: Int) async throws -> ResourceCollection<Post> {
        
        return .init(data: posts, links: .init(), meta: .init())
        
    }
    
}
