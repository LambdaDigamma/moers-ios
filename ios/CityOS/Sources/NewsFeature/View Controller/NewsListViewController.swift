//
//  NewsListViewController.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

#if canImport(UIKit)

import Foundation
import UIKit
import SwiftUI
import FeedKit
import Factory
import Core

public class NewsListViewController: UIHostingController<NewsList> {
    
    private var onShowArticle: (RSSFeedItem) -> Void
    private let newsService: NewsService
    
    @Injected(\.newsService) private var newsServiceFactory: NewsService?
    
    public init(onShowArticle: @escaping (RSSFeedItem) -> Void) {
        self.onShowArticle = onShowArticle
        self.newsService = newsServiceFactory ?? DefaultNewsService()
        super.init(rootView: NewsList(newsService: newsService, onShowArticle: onShowArticle))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserActivity.current = UserActivities.configureNewsList()
        
        self.userActivity = UserActivity.current
        self.userActivity?.becomeCurrent()
        
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

#endif
