//
//  FeedService.swift
//  
//
//  Created by Lennart Fischer on 06.02.21.
//

import Foundation
import ModernNetworking
import Cache

public protocol FeedService {
    
    func loadFeedFromNetwork(feedID: Feed.ID, perPage: Int) async throws -> Feed
    
    func loadPosts(for feedID: Feed.ID, page: Int, perPage: Int) async throws -> ResourceCollection<Post>
    
}
