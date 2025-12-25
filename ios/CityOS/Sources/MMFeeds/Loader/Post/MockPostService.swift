//
//  MockPostService.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import Foundation
import Combine
import ModernNetworking

public class MockPostService: PostService {
    
    private let result: Result<Post, Error>
    private let results: Result<[Post], Error>
    
    public init(result: Result<Post, Error>, results: Result<[Post], Error>) {
        self.result = result
        self.results = results
    }
    
    public func index(for feedID: Feed.ID, page: Int, perPage: Int, cacheMode: CacheMode) -> AnyPublisher<ResourceCollection<Post>, Error> {
        
        switch results {
            case .success(let success):
                return Just(ResourceCollection(data: success, links: .init(), meta: .init()))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            case .failure(let failure):
                return Fail(error: failure)
                    .eraseToAnyPublisher()
        }
        
    }
    
    public func index(for feedID: Feed.ID, page: Int, perPage: Int, cacheMode: CacheMode) async throws -> ResourceCollection<Post> {
        
        switch results {
            case .success(let success):
                return ResourceCollection(data: success, links: .init(), meta: .init())
            case .failure(let failure):
                throw failure
        }
        
    }
    
    public func show(for postID: Post.ID, cacheMode: CacheMode = .cached) async throws -> Resource<Post> {
        
        switch result {
            case .success(let success):
                return Resource(data: success)
            case .failure(let failure):
                throw failure
        }
        
    }
    
}
