//
//  DashboardCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 12.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMUI
import MMAPI

class DashboardCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    var rubbishManager: RubbishManagerProtocol
    var petrolManager: PetrolManagerProtocol
    
    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
         locationManager: LocationManagerProtocol,
         rubbishManager: RubbishManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         petrolManager: PetrolManagerProtocol) {
        
        self.navigationController = navigationController
        self.rubbishManager = rubbishManager
        self.petrolManager = petrolManager
        
        self.navigationController.coordinator = self
        self.navigationController.navigationBar.prefersLargeTitles = true
        
        let dashboardViewController = DashboardViewController(locationManager: locationManager,
                                                              geocodingManager: geocodingManager,
                                                              petrolManager: petrolManager)
        
        dashboardViewController.tabBarItem = generateTabBarItem()
        dashboardViewController.coordinator = self
        
        self.navigationController.viewControllers = [dashboardViewController]
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabControllerFactory = TabControllerFactory()
        
        let dashboardTabBarItem = tabControllerFactory.buildTabItem(
            using: ItemBounceContentView(),
            title: String.localized("DashboardTabItem"),
            image: #imageLiteral(resourceName: "dashboard"),
            accessibilityLabel: String.localized("DashboardTabItem"),
            accessibilityIdentifier: "TabDashboard")
        
        return dashboardTabBarItem
        
    }
    
    // MARK: - Navigation
    
    public func pushRubbishViewController() {
        
        let rubbishCollectionViewController = RubbishCollectionViewController()
        
        navigationController.pushViewController(rubbishCollectionViewController, animated: true)
        
    }
    
}
