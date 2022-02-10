//
//  DefaultNewsService.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import Foundation
import FeedKit
import Combine
import OSLog

public class DefaultNewsService: NewsService {
    
    private let logger: Logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "",
        category: "DefaultNewsService"
    )
    
    public init() {
        
    }
    
    public func loadNewsItems() -> AnyPublisher<[RSSFeedItem], Error> {
        
        return getRheinischePost()
            .map { (feed: RSSFeed) in
                return (feed.items ?? [])
                    .map({ (item: RSSFeedItem) in
                        let source = RSSFeedItemSource()
                        source.value = feed.title
                        item.source = source
                        return item
                    })
                    .sorted(by: { ($0.date > $1.date ) })
            }
            .eraseToAnyPublisher()
        
    }
    
    public func getRheinischePost() -> AnyPublisher<RSSFeed, Error> {
        
        return self.loadSource(url: URL(string: "https://rp-online.de/nrw/staedte/moers/feed.rss")!)
        
    }
    
    public func getLokalkompass() -> AnyPublisher<RSSFeed, Error> {
        
        return self.loadSource(url: URL(string: "https://www.lokalkompass.de/feed/action/mode/realm/ID/35/")!)
        
    }
    
    public func getNRZ() -> AnyPublisher<RSSFeed, Error> {
        
        return self.loadSource(url: URL(string: "https://www.nrz.de/?config=rss_moers_app")!)
        
    }
    
    private func loadSource(url: URL) -> AnyPublisher<RSSFeed, Error> {
        
        return Deferred {
            return Future { promise in
                
                let parser = FeedParser(URL: url)
                
                parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
                    
                    switch result {
                        
                        case .success(let feed):
                            
                            if let rssFeed = feed.rssFeed {
                                promise(.success(rssFeed))
                            } else {
                                self.logger.error("The provided feed is no rss feed.")
                                promise(.failure(URLError(.cannotDecodeRawData)))
                            }
                            
                        case .failure(let error):
                            self.logger.error("Failed loading feed: \(error.localizedDescription, privacy: .public)")
                            promise(.failure(error))
                            
                    }
                    
                }
                
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
}
