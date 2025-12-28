//
//  NewsViewModel.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import Factory
import Foundation
import Core
import FeedKit

@MainActor
public class NewsViewModel: StandardViewModel {
    
    @LazyInjected(\.newsService) private var newsService
    
    @Published public private(set) var newsItems: [RSSFeedItem] = []
    
    public override init() {
        
    }
    
    public func load() async {
        do {
            let items = try await newsService.loadNewsItems()
            self.newsItems = items
        } catch {
            print("Failed to load news items: \(error)")
        }
    }
    
}
