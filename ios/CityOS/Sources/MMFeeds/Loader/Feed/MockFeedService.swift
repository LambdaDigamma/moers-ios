//
//  MockFeedService.swift
//  
//
//  Created by Lennart Fischer on 06.02.21.
//

import Foundation
import ModernNetworking
import Core

public class MockFeedService: FeedService {
    
    private let posts: [Post]
    
    public init(posts: [Post] = Array.stub(withCount: 20)) {
        self.posts = posts
    }
    
    public func loadFeedFromNetwork(feedID: Feed.ID, perPage: Int) async throws -> Feed {
        
        let feed = Feed.stub(withID: feedID)
            .setting(\.name, to: "Main Feed")
            .setting(\.posts, to: posts)

        return feed
    }
    
    public func loadPosts(for feedID: Feed.ID, page: Int, perPage: Int) async throws -> ResourceCollection<Post> {
        
        return .init(data: posts, links: .init(), meta: .init())
        
    }
    
}