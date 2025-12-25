//
//  PostService.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import Combine
import ModernNetworking
import Cache

public protocol PostService {
    
    func index(for feedID: Feed.ID, page: Int, perPage: Int, cacheMode: CacheMode) -> AnyPublisher<ResourceCollection<Post>, Error>
    
    func index(for feedID: Feed.ID, page: Int, perPage: Int, cacheMode: CacheMode) async throws -> ResourceCollection<Post>
    
    func show(for postID: Post.ID, cacheMode: CacheMode) async throws -> Resource<Post>
    
}
