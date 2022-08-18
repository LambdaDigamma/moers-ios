//
//  NewsCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 07.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import AppScaffold
import SwiftUI
import NewsFeature
import FeedKit
import SafariServices

public class NewsCoordinator: NSObject, Coordinator, SFSafariViewControllerDelegate {
    
    public var navigationController: CoordinatedNavigationController
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        self.navigationController = navigationController
        super.init()
        
        self.navigationController.coordinator = self
        
        let newsViewController = NewsListViewController { (feedItem: RSSFeedItem) in
            
            guard let url = URL(string: feedItem.link ?? "") else { return }
            
            self.open(url: url)
            
        }
        
        newsViewController.navigationItem.largeTitleDisplayMode = .always
        newsViewController.title = AppStrings.Menu.news
        newsViewController.tabBarItem = generateTabBarItem()
//        newsViewController.coordinator = self
        
        self.navigationController.viewControllers = [newsViewController]
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.news,
            image: UIImage(systemName: "newspaper"),
            selectedImage: UIImage(systemName: "newspaper.fill")
        )
        tabBarItem.accessibilityLabel = AppStrings.Menu.news
        tabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.news
        
        return tabBarItem
        
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.topViewController?.navigationItem.largeTitleDisplayMode = .always
        
    }
    
    /// Opens a safari view controller for an article
    public func open(url: URL) {
        
        DispatchQueue.main.async {
            
            let svc = SFSafariViewController(url: url)
            svc.preferredBarTintColor = UIColor.systemBackground
            svc.preferredControlTintColor = UIColor.label
            svc.configuration.entersReaderIfAvailable = true
            svc.delegate = self
            
            self.navigationController.present(svc, animated: true) {
                self.navigationController.topViewController?.navigationItem.largeTitleDisplayMode = .never
            }
            
        }
        
    }
    
}
