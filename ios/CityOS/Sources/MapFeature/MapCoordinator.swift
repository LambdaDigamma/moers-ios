//
//  MapCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 13.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import AppScaffold
import FactoryKit

public class MapCoordintor: Coordinator {
    
    @LazyInjected(\.entryManager) var entryManager
    @LazyInjected(\.cameraManager) var cameraManager
    @LazyInjected(\.locationManager) var locationManager
    
    public var navigationController: CoordinatedNavigationController
    
    public var rootViewController: UIViewController { navigationController }
    
    public var tabBarItem: UITabBarItem? { rootViewController.tabBarItem }
    
    public var mainViewController: LegacyMainViewController?
    
    @MainActor
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
    
        self.navigationController = navigationController
        
        self.navigationController.coordinator = self
        
        let mapViewController = MapViewController()
        let contentViewController = SearchDrawerViewController()
        
        let mainViewController = LegacyMainViewController(
            contentViewController: mapViewController,
            drawerViewController: contentViewController
        )
        
//        let mainViewController = MainMapViewController()
        
        mainViewController.navigationItem.largeTitleDisplayMode = .never
        mainViewController.coordinator = self
        
        self.navigationController.menuItem = generateMenuItem()
        
        self.navigationController.viewControllers = [mainViewController]
        self.mainViewController = mainViewController
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
        self.navigationController.isNavigationBarHidden = true
        
    }
    
    @MainActor private func generateMenuItem() -> MenuItem {

        MenuItem(
            title: AppStrings.Menu.map,
            image: UIImage(systemName: "map"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.map
        )
        
    }
    
    @MainActor
    public func showSearch() {
        
        mainViewController?.setDrawerPosition(position: .open, animated: true)
        mainViewController?.contentViewController.searchDrawer.searchBar.becomeFirstResponder()
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
