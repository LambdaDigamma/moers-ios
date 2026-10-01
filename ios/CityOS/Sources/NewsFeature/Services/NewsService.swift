//
//  NewsService.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import Foundation
import FeedKit

nonisolated public protocol NewsService {
    
    func loadNewsItems() async throws -> [RSSFeedItem]
    
}
