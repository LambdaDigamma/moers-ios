//
//  Container+FeedService.swift
//  MMFeeds
//
//  Created for Factory migration
//

import Foundation
import FactoryKit
import ModernNetworking
import Core
import Cache

public extension Container {
    
    @MainActor var feedService: Factory<FeedService> {
        self {
            DefaultFeedService(
                client: self.httpClient(),
                try! Storage<String, Feed>(
                    diskConfig: DiskConfig(name: "FeedService"),
                    memoryConfig: MemoryConfig(),
                    fileManager: .default,
                    transformer: TransformerFactory.forCodable(ofType: Feed.self)
                )
            )
        }
        .singleton
    }
    
}
