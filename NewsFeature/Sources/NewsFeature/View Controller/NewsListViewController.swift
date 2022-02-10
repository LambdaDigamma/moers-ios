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
import Resolver

public class NewsListViewController: UIHostingController<NewsList> {
    
    private var onShowArticle: (RSSFeedItem) -> Void
    private let newsService: NewsService
    
    public init(onShowArticle: @escaping (RSSFeedItem) -> Void) {
        self.onShowArticle = onShowArticle
        self.newsService = Resolver.resolve()
        super.init(rootView: NewsList(newsService: newsService, onShowArticle: onShowArticle))
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

#endif
