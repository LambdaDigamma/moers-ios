//
//  OtherCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 14.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMUI
import MMAPI
import AppScaffold

class OtherCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    
    var otherViewController: OtherViewController?
    
    public let entryManager: EntryManagerProtocol
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        entryManager: EntryManagerProtocol
    ) {
        
        self.navigationController = navigationController
        self.entryManager = entryManager
        
        let otherViewController = OtherViewController(
            entryManager: entryManager
        )
        
        otherViewController.tabBarItem = generateTabBarItem()
        otherViewController.coordinator = self
        
        self.navigationController.coordinator = self
        self.navigationController.viewControllers = [otherViewController]
        self.otherViewController = otherViewController
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.other,
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )
        
        tabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.other
        
        return tabBarItem
        
    }
    
}
