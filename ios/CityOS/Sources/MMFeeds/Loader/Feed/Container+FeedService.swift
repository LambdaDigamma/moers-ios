//
//  Container+FeedService.swift
//  MMFeeds
//
//  Created for Factory migration
//

import Foundation
import Factory
import ModernNetworking
import Core
import Cache

public extension Container {
    
    var feedService: Factory<FeedService> {
        self {
            DefaultFeedService(
                self.httpLoader(),
                try! Storage<String, Feed>(
                    diskConfig: DiskConfig(name: "FeedService"),
                    memoryConfig: MemoryConfig(),
                    transformer: TransformerFactory.forCodable(ofType: Feed.self)
                )
            )
        }
        .singleton
    }
    
}
