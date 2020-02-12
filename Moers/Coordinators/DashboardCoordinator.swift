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
    var locationManager: LocationManagerProtocol
    var geocodingManager: GeocodingManagerProtocol
    
    var dashboardViewController: DashboardViewController?
    
    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
         locationManager: LocationManagerProtocol,
         rubbishManager: RubbishManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         petrolManager: PetrolManagerProtocol) {
        
        self.navigationController = navigationController
        self.rubbishManager = rubbishManager
        self.petrolManager = petrolManager
        self.locationManager = locationManager
        self.geocodingManager = geocodingManager
        
        self.navigationController.coordinator = self
        
        let dashboardViewController = DashboardViewController(coordinator: self)
        
        dashboardViewController.tabBarItem = generateTabBarItem()
        
        self.navigationController.viewControllers = [dashboardViewController]
        self.dashboardViewController = dashboardViewController
        
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
    
    public func updateUI() {
        
        dashboardViewController?.reloadUI()
        dashboardViewController?.triggerUpdate()
        
    }
    
}
