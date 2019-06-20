//
//  NewsItem.swift
//  Moers
//
//  Created by Lennart Fischer on 23.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import TwitterKit
import FeedKit

protocol NewsItem {
    
    var date: Date { get }
    
}

extension TWTRTweet: NewsItem {
    
    var date: Date {
        return self.createdAt
    }
    
}

extension RSSFeedItem: NewsItem {
    
    var date: Date {
        return self.pubDate ?? Date()
    }
    
}
