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
    
    public let locationManager: LocationManagerProtocol
    public let entryManager: EntryManagerProtocol
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        locationManager: LocationManagerProtocol,
        entryManager: EntryManagerProtocol
    ) {
        
        self.navigationController = navigationController
        self.locationManager = locationManager
        self.entryManager = entryManager
        
        let otherViewController = OtherViewController(
            entryManager: entryManager
        )
        
        otherViewController.tabBarItem = generateTabBarItem()
        otherViewController.coordinator = self
        
        self.navigationController.coordinator = self
        self.navigationController.viewControllers = [otherViewController]
        self.otherViewController = otherViewController
        
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
