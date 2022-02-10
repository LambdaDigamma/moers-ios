//
//  NewsViewModel.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import Foundation
import Combine
import Core
import FeedKit

public class NewsViewModel: StandardViewModel {
    
    @Published public private(set) var newsItems: [RSSFeedItem] = []
    
    private let newsService: NewsService
    
    public init(newsService: NewsService) {
        self.newsService = newsService
    }
    
    public func load() {
        
        newsService.loadNewsItems()
            .sink { (_: Subscribers.Completion<Error>) in
                
            } receiveValue: { (items: [RSSFeedItem]) in
                self.newsItems = items
            }
            .store(in: &cancellables)
        
    }
    
}
