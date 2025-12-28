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
        Task {
            do {
                let items = try await newsService.loadNewsItems()
                await MainActor.run {
                    self.newsItems = items
                }
            } catch {
                print("Failed to load news items: \(error)")
            }
        }
    }
    
}
