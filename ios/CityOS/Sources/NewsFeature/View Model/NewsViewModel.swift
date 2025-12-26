//
//  NewsViewModel.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import Factory
import Foundation
import Combine
import Core
import FeedKit

public class NewsViewModel: StandardViewModel {
    
    @LazyInjected(\.newsService) private var newsService
    
    @Published public private(set) var newsItems: [RSSFeedItem] = []
    
    public override init() {
        
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
