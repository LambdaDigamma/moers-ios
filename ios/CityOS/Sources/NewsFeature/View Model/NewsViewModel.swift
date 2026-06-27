//
//  NewsViewModel.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import FactoryKit
import Foundation
import Core
import FeedKit
import Observation

@MainActor
@Observable
public class NewsViewModel: StandardViewModel {
    
    @ObservationIgnored @LazyInjected(\.newsService) private var newsService
    
    public private(set) var newsItems: [RSSFeedItem] = []
    
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
