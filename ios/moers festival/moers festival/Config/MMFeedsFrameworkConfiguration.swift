//
//  MMFeedsFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
@preconcurrency import ModernNetworking
import Cache
import MMFeeds
import Factory

class MMFeedsFrameworkConfiguration: BootstrappingProcedureStep {

    func execute(with application: UIApplication) {

        if LaunchArgumentsHandler.shouldUseMockedFeed {
            Container.shared.feedService.register {
                Self.createMockedFeedService()
            }

            return
        }

        Container.shared.feedService.register {
            let cache = try! Storage<String, Feed>(
                diskConfig: DiskConfig(name: "FeedService"),
                memoryConfig: MemoryConfig(),
                fileManager: .default,
                transformer: TransformerFactory.forCodable(ofType: Feed.self)
            )

            return DefaultFeedService(Container.shared.httpLoader.resolve(), cache) as FeedService
        }

        Container.shared.postRepository.scope(.cached).register {
            let service = FestivalNewsPostService(Container.shared.httpLoader.resolve())
            let appDatabase = Container.shared.appDatabase.resolve()
            let store = PostStore(
                writer: appDatabase.dbWriter,
                reader: appDatabase.reader
            )

            return PostRepository(service: service, store: store)
        }

    }

    nonisolated private static func createMockedFeedService() -> MockFeedService {

        let mockedPosts = [
            Post.stub(withID: 1)
                .setting(\.title, to: "Post1Title")
                .setting(\.summary, to: "Post1Summary"),
            Post.stub(withID: 2)
                .setting(\.title, to: "Post2Title")
                .setting(\.summary, to: "Post2Summary"),
            Post.stub(withID: 3)
                .setting(\.title, to: "Post3Title")
                .setting(\.summary, to: "Post3Summary")
        ]

        return MockFeedService(posts: mockedPosts)

    }

}

nonisolated private final class FestivalNewsPostService: PostService {

    nonisolated(unsafe) private let loader: HTTPLoader
    private let defaultService: DefaultPostService

    init(_ loader: HTTPLoader) {
        self.loader = loader
        self.defaultService = DefaultPostService(loader)
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
            meta: resource.meta
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
