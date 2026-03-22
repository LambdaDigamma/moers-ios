//
//  DefaultNewsService.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import Foundation
import FeedKit
import OSLog
import Core

public struct DefaultNewsService: NewsService, Sendable {
    
    private let logger: Logger = Logger(.coreApi)
    
    public init() {
        
    }
    
    public func loadNewsItems() async throws -> [RSSFeedItem] {
        
        async let rpFeed = getRheinischePost()
        async let lkFeed = getLokalkompass()
        
        let (rp, lk) = try await (rpFeed, lkFeed)
        
        let allItems = (rp.channel?.items.clean(settingSource: "RP Online") ?? []) + (lk.channel?.items.clean(settingSource: "Lokalkompass") ?? [])
        
        return allItems
            .sorted { $0.date > $1.date }
        
    }
    
    public func getRheinischePost() async throws -> RSSFeed {
        return try await self.loadSource(url: URL(string: "https://rp-online.de/nrw/staedte/moers/feed.rss")!)
    }
    
    public func getLokalkompass() async throws -> RSSFeed {
        return try await self.loadSource(url: URL(string: "https://www.lokalkompass.de/moers/rss")!)
    }
    
    public func getNRZ() async throws -> RSSFeed {
        return try await self.loadSource(url: URL(string: "https://www.nrz.de/?config=rss_moers_app")!)
    }
    
    private func loadSource(url: URL) async throws -> RSSFeed {
        
        let feed = try await Feed(remoteURL: url)
        
        if let rss = feed.rss {
            return rss
        } else {
            throw URLError(.cannotDecodeRawData)
        }
        
    }
    
}

public extension Optional<[RSSFeedItem]> {
    
    func clean(settingSource source: String) -> [RSSFeedItem] {
        
        guard let items = self else {
            return []
        }
        
        return items.map { item in
            var item = item
            let itemSource = RSSFeedSource(text: source)
            item.source = itemSource
            return item
        }
        
    }
    
}
