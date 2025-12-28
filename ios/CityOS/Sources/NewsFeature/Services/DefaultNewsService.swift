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

public class DefaultNewsService: NewsService {
    
    private let logger: Logger = Logger(.coreApi)
    
    public init() {
        
    }
    
    public func loadNewsItems() async throws -> [RSSFeedItem] {
        let feed = try await getRheinischePost()
        return (feed.items ?? [])
            .map { item in
                let source = RSSFeedItemSource()
                source.value = feed.title
                item.source = source
                return item
            }
            .sorted(by: { ($0.date > $1.date ) })
    }
    
    public func getRheinischePost() async throws -> RSSFeed {
        return try await self.loadSource(url: URL(string: "https://rp-online.de/nrw/staedte/moers/feed.rss")!)
    }
    
    public func getLokalkompass() async throws -> RSSFeed {
        return try await self.loadSource(url: URL(string: "https://www.lokalkompass.de/feed/action/mode/realm/ID/35/")!)
    }
    
    public func getNRZ() async throws -> RSSFeed {
        return try await self.loadSource(url: URL(string: "https://www.nrz.de/?config=rss_moers_app")!)
    }
    
    private func loadSource(url: URL) async throws -> RSSFeed {
        return try await withCheckedThrowingContinuation { continuation in
            let parser = FeedParser(URL: url)
            
            parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { [weak self] result in
                switch result {
                case .success(let feed):
                    if let rssFeed = feed.rssFeed {
                        continuation.resume(returning: rssFeed)
                    } else {
                        self?.logger.error("The provided feed is no rss feed.")
                        continuation.resume(throwing: URLError(.cannotDecodeRawData))
                    }
                    
                case .failure(let error):
                    self?.logger.error("Failed loading feed: \(error.localizedDescription, privacy: .public)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
