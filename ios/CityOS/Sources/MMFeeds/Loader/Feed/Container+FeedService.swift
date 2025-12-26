//
//  Container+FeedService.swift
//  MMFeeds
//
//  Created for Factory migration
//

import Foundation
import Factory
import ModernNetworking

public extension Container {
    
    var feedService: Factory<FeedService> {
        self {
            DefaultFeedService(loader: self.httpLoader())
        }
        .singleton
    }
    
}
