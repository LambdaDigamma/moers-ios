//
//  NewsCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 07.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI
import MMUI
import AppScaffold

class NewsCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    
    init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        
        self.navigationController = navigationController
        self.navigationController.coordinator = self
        
        let newsViewController = NewsViewController()
        
        newsViewController.navigationItem.largeTitleDisplayMode = .never
        newsViewController.tabBarItem = generateTabBarItem()
        newsViewController.coordinator = self
        
        self.navigationController.viewControllers = [newsViewController]
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.news,
            image: UIImage(systemName: "map"),
            selectedImage: UIImage(systemName: "map.fill")
        )
        tabBarItem.accessibilityLabel = AppStrings.Menu.news
        tabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.news
        
        return tabBarItem
        
    }
    
}
