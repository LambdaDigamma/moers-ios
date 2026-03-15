//
//  NewsCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import SwiftUI
import AppScaffold
import ModernNetworking
import Cache
import MMPages
import MMFeeds
import SafariServices
import Combine
import Factory

public class NewsCoordinator: Coordinator {
    
    @LazyInjected(\.feedService) private var feedService
    @LazyInjected(\.pageRepository) private var repository
    
    public var navigationController: CoordinatedNavigationController
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Setup
    
    public init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
        
        self.navigationController = navigationController
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        self.navigationController.menuItem = makeMenuItem()
        
        let newsViewController = PostsViewController(feedID: 3) { (postID: Post.ID) in
            self.showPost(postID: postID)
        }
        
        newsViewController.title = self.navigationController.menuItem?.title
        
        self.navigationController.viewControllers = [newsViewController]
        
    }
    
    private func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.News.title,
            image: UIImage(systemName: "newspaper"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.news
        )
        
    }
    
    // MARK: - Navigation Actions
    
    public func showNews() {
        
//        navigationController.pushViewController(PageViewController(), animated: true)
        
    }
    
    public func showPost(postID: Post.ID, animated: Bool = true) {
        
        let postDetailViewController = PostDetailViewController(postID: postID)
        self.navigationController.pushViewController(postDetailViewController, animated: animated)
        
    }
    
    private func openLink(url: URL) {

        DispatchQueue.main.async {
            let externalViewController = ExternalWebViewController(url: url)
            externalViewController.navigationItem.largeTitleDisplayMode = .never

            self.navigationController.pushViewController(externalViewController, animated: true)
        }

    }
    
}
