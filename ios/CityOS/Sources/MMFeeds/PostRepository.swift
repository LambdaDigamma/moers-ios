//
//  PostRepository.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import Combine
import GRDB
import Factory

public extension Container {
    var postRepository: Factory<PostRepository> {
        Factory(self) {
            
            guard let dbQueue = try? DatabaseQueue(path: ":memory:") else { fatalError() }
            
            return PostRepository(
                service: MockPostService(result: .success(Post.stub(withID: 1)), results: .success([Post].stub(withCount: 4))),
                store: .init(writer: dbQueue, reader: dbQueue)
            )
            
        }.singleton
    }
}


public class PostRepository {
    
    private let service: PostService
    private let store: PostStore
    
    public init(
        service: PostService,
        store: PostStore
    ) {
        self.service = service
        self.store = store
    }
    
    // MARK: - UI Sources
    
    public func postPublisher(postID: Post.ID) -> AnyPublisher<Post?, Error> {
        
        return store.postObserver(postID: postID)
            .map { $0?.toBase() }
            .eraseToAnyPublisher()
        
    }
    
    public func postsPublisher(feedID: Feed.ID) -> AnyPublisher<[Post], Error> {
        
        return store.feedObserver(feedID: feedID, numberOfPosts: 50)
            .map { $0.map { $0.toBase() } }
            .eraseToAnyPublisher()
        
    }
    
    // MARK: - Networking
    
    /// Refreshes the post while skipping all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    public func refreshPost(for postID: Post.ID) async throws {
        
        let resource = try await service.show(for: postID, cacheMode: .revalidate)
        
        try await updateStore(posts: [resource.data])
        
    }
    
    /// Reloads the post while going through all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    ///
    /// It throws an error when an error occurs while loading the
    /// data from the network.
    public func reloadPost(for postID: Post.ID) async throws {
        
        let resource = try await service.show(for: postID, cacheMode: .cached)
        
        try await updateStore(posts: [resource.data])
        
    }
    
    /// Refreshes the post while skipping all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    public func refreshFeed(for feedID: Feed.ID, perPage: Int = 50) async throws {
        
        let resource = try await service.index(for: feedID, page: 1, perPage: perPage, cacheMode: .revalidate)
        
        try await updateStore(posts: resource.data)
        
    }
    
    /// Reloads the feed while going through all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    ///
    /// - Throws: An error when an error occurs while loading the
    /// data from the network.
    public func reloadFeed(for feedID: Feed.ID, perPage: Int = 50) async throws {
        
        let resource = try await service.index(for: feedID, page: 1, perPage: perPage, cacheMode: .cached)
        
        try await updateStore(posts: resource.data)
        
    }
    
    // MARK: - Database Handling
    
    /// Write the post to the database.
    ///
    /// - Throws: any errors from the underlying database implementation.
    private func updateStore(posts: [Post]) async throws {
        
        try await store.updateOrCreate(posts.map { $0.toRecord() })
        
    }
    
}
