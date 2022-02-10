//
//  NewsItem.swift
//  Moers
//
//  Created by Lennart Fischer on 23.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import FeedKit

public protocol NewsItem: Hashable {
    
    var date: Date { get }
    
}

extension RSSFeedItem: NewsItem {
    
    public var date: Date {
        return self.pubDate ?? Date()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.guid?.value)
        hasher.combine(self.title)
        hasher.combine(self.description)
    }
    
}
