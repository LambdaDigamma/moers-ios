//
//  NewsService.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import Foundation
import Combine
import FeedKit

public protocol NewsService {
    
    func loadNewsItems() -> AnyPublisher<[RSSFeedItem], Error>
    
}
