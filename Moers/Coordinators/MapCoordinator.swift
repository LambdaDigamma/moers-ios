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

class MapCoordintor: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    
    var locationManager: LocationManagerProtocol
    var petrolManager: PetrolManagerProtocol
    var cameraManager: CameraManagerProtocol
    var entryManager: EntryManagerProtocol
    var parkingLotManager: ParkingLotManagerProtocol
    
    var mainViewController: MainViewController?
    
    init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        locationManager: LocationManagerProtocol,
        petrolManager: PetrolManagerProtocol,
        cameraManager: CameraManagerProtocol,
        entryManager: EntryManagerProtocol,
        parkingLotManager: ParkingLotManagerProtocol
    ) {
    
        self.navigationController = navigationController
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        self.parkingLotManager = parkingLotManager
        
        self.navigationController.coordinator = self
        
        let mapViewController = MapViewController()
        let contentViewController = SearchDrawerViewController(locationManager: locationManager)
        
        let mainViewController = MainViewController(
            contentViewController: mapViewController,
            drawerViewController: contentViewController,
            petrolManager: petrolManager,
            cameraManager: cameraManager,
            entryManager: entryManager,
            parkingLotManager: parkingLotManager
        )
        
        mainViewController.navigationItem.largeTitleDisplayMode = .never
        mainViewController.tabBarItem = generateTabBarItem()
        mainViewController.coordinator = self
        
        self.navigationController.viewControllers = [mainViewController]
        self.mainViewController = mainViewController
        
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
