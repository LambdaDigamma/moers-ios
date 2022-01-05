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
import AppScaffold
import SwiftUI
import DashboardFeature

class DashboardCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    var petrolManager: PetrolManagerProtocol
    var locationManager: LocationManagerProtocol
    var geocodingManager: GeocodingManagerProtocol
    
    var dashboardViewController: DashboardViewController?
    
    init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        locationManager: LocationManagerProtocol,
        geocodingManager: GeocodingManagerProtocol,
        petrolManager: PetrolManagerProtocol
    ) {
        
        self.navigationController = navigationController
        self.petrolManager = petrolManager
        self.locationManager = locationManager
        self.geocodingManager = geocodingManager
        
        self.navigationController.coordinator = self
        
//        let dashboard = DashboardView()
//        let hostingController = UIHostingController(rootView: dashboard)
//
//        hostingController.tabBarItem = generateTabBarItem()
//        self.navigationController.viewControllers = [hostingController]
        
        let dashboard = DashboardView()
        let controller = UIHostingController(rootView: dashboard)
        
        controller.tabBarItem = generateTabBarItem()
        
        self.navigationController.viewControllers = [controller]
//        self.dashboardViewController = controller
        
//        let dashboardViewController = DashboardViewController(coordinator: self)
//        dashboardViewController.tabBarItem = generateTabBarItem()
//
//        self.navigationController.viewControllers = [dashboardViewController]
//        self.dashboardViewController = dashboardViewController
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: String.localized("DashboardTabItem"),
            image: UIImage(systemName: "rectangle.grid.2x2"),
            selectedImage: UIImage(systemName: "rectangle.grid.2x2.fill")
        )
        
        tabBarItem.accessibilityIdentifier = "TabDashboard"
        
        return tabBarItem
        
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
