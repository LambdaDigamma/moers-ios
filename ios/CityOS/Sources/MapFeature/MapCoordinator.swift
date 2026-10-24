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
    
    public var rootViewController: UIViewController { mainViewController }
    
    public var tabBarItem: UITabBarItem? { rootViewController.tabBarItem }
    
    public let mainViewController: MapContainerViewController
    
    @MainActor
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
    
        self.navigationController = navigationController
        
        self.mainViewController = MapContainerViewController(panelNavigationController: navigationController)
        self.navigationController.coordinator = self
        let mainViewController = self.mainViewController

        mainViewController.coordinator = self
        
        let menu = generateMenuItem()
        self.navigationController.menuItem = menu
        mainViewController.title = menu.title
        mainViewController.tabBarItem = UITabBarItem(title: menu.title, image: menu.image, tag: 0)
        mainViewController.tabBarItem.accessibilityLabel = menu.title
        mainViewController.tabBarItem.accessibilityIdentifier = menu.accessibilityIdentifier
        
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
        
        mainViewController.showSearch(focusSearch: true)

    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
