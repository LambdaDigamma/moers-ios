//
//  MapCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 13.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI
import MMUI
import AppScaffold
import Core

public class MapCoordintor: Coordinator {
    
    public var navigationController: CoordinatedNavigationController
    
    public var locationManager: LocationManagerProtocol
    public var petrolManager: PetrolManagerProtocol
    public var cameraManager: CameraManagerProtocol
    public var entryManager: EntryManagerProtocol
    
    public var mainViewController: MainViewController?
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        locationManager: LocationManagerProtocol,
        petrolManager: PetrolManagerProtocol,
        cameraManager: CameraManagerProtocol,
        entryManager: EntryManagerProtocol
    ) {
    
        self.navigationController = navigationController
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        
        self.navigationController.coordinator = self
        
        let mapViewController = MapViewController()
        let contentViewController = SearchDrawerViewController(locationManager: locationManager)
        
        let mainViewController = MainViewController(
            contentViewController: mapViewController,
            drawerViewController: contentViewController,
            petrolManager: petrolManager,
            cameraManager: cameraManager,
            entryManager: entryManager
        )
        
        mainViewController.navigationItem.largeTitleDisplayMode = .never
        mainViewController.tabBarItem = generateTabBarItem()
        mainViewController.coordinator = self
        
        self.navigationController.viewControllers = [mainViewController]
        self.mainViewController = mainViewController
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.map,
            image: UIImage(systemName: "map"),
            selectedImage: UIImage(systemName: "map.fill")
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
