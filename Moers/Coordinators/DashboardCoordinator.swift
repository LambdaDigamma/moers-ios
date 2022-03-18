//
//  DashboardCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 12.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import MMUI
import MMAPI
import AppScaffold
import SwiftUI
import DashboardFeature
import RubbishFeature
import FuelFeature

class DashboardCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    var petrolManager: PetrolManagerProtocol
    
    var dashboardViewController: DashboardViewController?
    
    init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        petrolManager: PetrolManagerProtocol
    ) {
        
        self.navigationController = navigationController
        self.petrolManager = petrolManager
        
        self.navigationController.coordinator = self
        
        let dashboard = DashboardView()
        let controller = UIHostingController(rootView: dashboard)
        let activity = UserActivities.configureDashboardActivity()
        
        controller.tabBarItem = generateTabBarItem()
        controller.userActivity = activity
        
        activity.becomeCurrent()
        
        self.navigationController.viewControllers = [controller]
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.dashboard,
            image: UIImage(systemName: "doc.text.image"), // "rectangle.grid.2x2"
            selectedImage: UIImage(systemName: "doc.text.image") // "rectangle.grid.2x2.fill"
        )
        
        tabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.dashboard
        
        return tabBarItem
        
    }
    
    // MARK: - Navigation
    
    public func pushRubbishViewController() {
        
        let rubbishCollectionViewController = RubbishScheduleController()
        
        navigationController.popToRootViewController(animated: true)
        navigationController.pushViewController(rubbishCollectionViewController, animated: true)
        
    }
    
    public func pushFuelStationListViewController() {
        
        let rubbishCollectionViewController = FuelStationListViewController()
        
        navigationController.popToRootViewController(animated: true)
        navigationController.pushViewController(rubbishCollectionViewController, animated: true)
        
    }
    
    public func updateUI() {
        
        dashboardViewController?.reloadUI()
        dashboardViewController?.triggerUpdate()
        
    }
    
}
