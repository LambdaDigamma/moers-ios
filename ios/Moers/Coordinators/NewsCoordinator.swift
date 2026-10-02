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

    public var rootViewController: UIViewController { navigationController }

    public var tabBarItem: UITabBarItem? { rootViewController.tabBarItem }
    
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
//        newsViewController.coordinator = self
        
        self.navigationController.viewControllers = [newsViewController]
        self.navigationController.menuItem = generateMenuItem()
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
    }
    
    private func generateMenuItem() -> MenuItem {

        MenuItem(
            title: AppStrings.Menu.news,
            image: UIImage(systemName: "newspaper"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.news
        )
        
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.topViewController?.navigationItem.largeTitleDisplayMode = .always
        
    }
    
    /// Opens a safari view controller for an article
    public func open(url: URL) {

        let svc = SFSafariViewController(url: url)
        svc.preferredBarTintColor = UIColor.systemBackground
        svc.preferredControlTintColor = UIColor.label
        svc.configuration.entersReaderIfAvailable = true
        svc.delegate = self

        self.navigationController.present(svc, animated: true) {
            self.navigationController.topViewController?.navigationItem.largeTitleDisplayMode = .never
        }

    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
