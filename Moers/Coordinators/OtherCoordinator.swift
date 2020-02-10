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

class OtherCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    
    var otherViewController: OtherViewController?
    
    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
         locationManager: LocationManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         rubbishManager: RubbishManagerProtocol,
         petrolManager: PetrolManagerProtocol,
         entryManager: EntryManagerProtocol) {
        
        self.navigationController = navigationController
        
        let otherViewController = OtherViewController(locationManager: locationManager,
                                                      geocodingManager: geocodingManager,
                                                      rubbishManager: rubbishManager,
                                                      petrolManager: petrolManager,
                                                      entryManager: entryManager)
        
        otherViewController.tabBarItem = generateTabBarItem()
        otherViewController.coordinator = self
        
        self.navigationController.coordinator = self
        self.navigationController.viewControllers = [otherViewController]
        self.otherViewController = otherViewController
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabControllerFactory = TabControllerFactory()
        
        let otherTabBarItem = tabControllerFactory.buildTabItem(
            using: ItemBounceContentView(),
            title: String.localized("OtherTabItem"),
            image: #imageLiteral(resourceName: "list"),
            accessibilityLabel: String.localized("OtherTabItem"),
            accessibilityIdentifier: "TabOther")
        
        return otherTabBarItem
        
    }
    
}
