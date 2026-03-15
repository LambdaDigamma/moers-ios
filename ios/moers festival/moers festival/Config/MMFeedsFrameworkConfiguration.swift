//
//  MMFeedsFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import ModernNetworking
import Cache
import MMFeeds
import Factory
import Combine

class MMFeedsFrameworkConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        
        let loader = Container.shared.httpLoader.resolve()
        
        do {
            
            if LaunchArgumentsHandler.shouldUseMockedFeed {
                
                let mockedFeedService = createMockedFeedService()
                
                Container.shared.feedService.register {
                    mockedFeedService
                }
                
                return
            }
            
            let cache = try Storage<String, Feed>(
                diskConfig: DiskConfig(name: "FeedService"),
                memoryConfig: MemoryConfig(),
                transformer: TransformerFactory.forCodable(ofType: Feed.self))
            
            let service = DefaultFeedService(loader, cache)
            
            Container.shared.feedService.register {
                service as FeedService
            }
            
        } catch {
            
            print("Failed to create event cache.")
            print(error.localizedDescription)
            
        }
        
        let service = FestivalNewsPostService(loader)
        let store = PostStore(
            writer: Container.shared.appDatabase.resolve().dbWriter,
            reader: Container.shared.appDatabase.resolve().reader
        )
        
        Container.shared.postRepository.scope(.cached).register {
            PostRepository(service: service, store: store)
        }
        
    }
    
    private func createMockedFeedService() -> MockFeedService {
        
        let mockedPosts = [
            Post.stub(withID: 1)
                .setting(\.title, to: "Post1Title".localized(in: "MockData"))
                .setting(\.summary, to: "Post1Summary".localized(in: "MockData")),
            Post.stub(withID: 2)
                .setting(\.title, to: "Post2Title".localized(in: "MockData"))
                .setting(\.summary, to: "Post2Summary".localized(in: "MockData")),
            Post.stub(withID: 3)
                .setting(\.title, to: "Post3Title".localized(in: "MockData"))
                .setting(\.summary, to: "Post3Summary".localized(in: "MockData"))
        ]
        
        return MockFeedService(posts: mockedPosts)
        
    }
    
}

private final class FestivalNewsPostService: PostService {
    
    private let loader: HTTPLoader
    private let defaultService: DefaultPostService
    
    init(_ loader: HTTPLoader = URLSessionLoader()) {
        self.loader = loader
        self.defaultService = DefaultPostService(loader)
    }
    
    func index(for feedID: Feed.ID, page: Int, perPage: Int, cacheMode: CacheMode) -> AnyPublisher<ResourceCollection<Post>, Error> {
        
        var request = Self.indexRequest(page: page, perPage: perPage)
        
        request.cachePolicy = cacheMode.policy
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { result in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
        .compactMap { $0.body }
        .decode(type: ResourceCollection<Post>.self, decoder: Feed.decoder)
        .map { resource in
            ResourceCollection(
                data: resource.data.map { post in
                    var normalizedPost = post
                    normalizedPost.feedID = normalizedPost.feedID ?? feedID
                    return normalizedPost
                },
                links: resource.links ?? ResourceLinks(),
                meta: resource.meta ?? ResourceMeta()
            )
        }
        .eraseToAnyPublisher()
        
    }
    
    func index(for feedID: Feed.ID, page: Int, perPage: Int, cacheMode: CacheMode) async throws -> ResourceCollection<Post> {
        
        var request = Self.indexRequest(page: page, perPage: perPage)
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        let resource = try await result.decoding(ResourceCollection<Post>.self)
        
        return ResourceCollection(
            data: resource.data.map { post in
                var normalizedPost = post
                normalizedPost.feedID = normalizedPost.feedID ?? feedID
                return normalizedPost
            },
            links: resource.links ?? ResourceLinks(),
            meta: resource.meta ?? ResourceMeta()
        )
        
    }
    
    func show(for postID: Post.ID, cacheMode: CacheMode) async throws -> Resource<Post> {
        try await defaultService.show(for: postID, cacheMode: cacheMode)
    }
    
    private static func indexRequest(page: Int, perPage: Int) -> HTTPRequest {
        
        var request = HTTPRequest(path: "news")
        
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(perPage)),
            URLQueryItem(name: "page[number]", value: String(page))
        ]
        
        return request
        
    }
    
}
