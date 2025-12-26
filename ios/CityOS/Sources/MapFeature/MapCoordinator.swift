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
import Factory

public class MapCoordintor: Coordinator {
    
    @LazyInjected(\.entryManager) var entryManager
    @LazyInjected(\.cameraManager) var cameraManager
    @LazyInjected(\.locationManager) var locationManager
    
    public var navigationController: CoordinatedNavigationController
    
    public var mainViewController: MainViewController?
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
    
        self.navigationController = navigationController
        
        self.navigationController.coordinator = self
        
        let mapViewController = MapViewController()
        let contentViewController = SearchDrawerViewController()
        
        let mainViewController = MainViewController(
            contentViewController: mapViewController,
            drawerViewController: contentViewController
        )
        
        mainViewController.navigationItem.largeTitleDisplayMode = .never
        mainViewController.tabBarItem = generateTabBarItem()
        mainViewController.coordinator = self
        
        self.navigationController.viewControllers = [mainViewController]
        self.mainViewController = mainViewController
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
        self.navigationController.isNavigationBarHidden = true
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.map,
            image: UIImage(systemName: "map"),
            selectedImage: UIImage(systemName: "map")
        )
        
        tabBarItem.accessibilityLabel = AppStrings.Menu.map
        tabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.map
        
        return tabBarItem
        
    }
    
    public func showSearch() {
        
        mainViewController?.setDrawerPosition(position: .open, animated: true)
        mainViewController?.contentViewController.searchDrawer.searchBar.becomeFirstResponder()
        
    }
    
}
