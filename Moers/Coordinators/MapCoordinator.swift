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

class MapCoordintor: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    
    var locationManager: LocationManagerProtocol
    var petrolManager: PetrolManagerProtocol
    var cameraManager: CameraManagerProtocol
    var entryManager: EntryManagerProtocol
    var parkingLotManager: ParkingLotManagerProtocol
    
    var mainViewController: MainViewController?
    
    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
         locationManager: LocationManagerProtocol,
         petrolManager: PetrolManagerProtocol,
         cameraManager: CameraManagerProtocol,
         entryManager: EntryManagerProtocol,
         parkingLotManager: ParkingLotManagerProtocol) {
        
        self.navigationController = navigationController
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        self.parkingLotManager = parkingLotManager
        
        self.navigationController.coordinator = self
        
        let mapViewController = MapViewController(locationManager: locationManager)
        let contentViewController = SearchDrawerViewController(locationManager: locationManager)
        
        let mainViewController = MainViewController(contentViewController: mapViewController,
                                                    drawerViewController: contentViewController,
                                                    locationManager: locationManager,
                                                    petrolManager: petrolManager,
                                                    cameraManager: cameraManager,
                                                    entryManager: entryManager,
                                                    parkingLotManager: parkingLotManager)
        
        mainViewController.tabBarItem = generateTabBarItem()
        mainViewController.coordinator = self
        
        self.navigationController.viewControllers = [mainViewController]
        self.mainViewController = mainViewController
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabControllerFactory = TabControllerFactory()
        
        let mapTabBarItem = tabControllerFactory.buildTabItem(
            using: MapItemContentView(),
            image: #imageLiteral(resourceName: "map_marker"),
            accessibilityLabel: String.localized("MapTabItem"),
            accessibilityIdentifier: "TabMap")
        
        return mapTabBarItem
        
    }
    
    public func showSearch() {
        
        mainViewController?.setDrawerPosition(position: .open, animated: true)
        mainViewController?.contentViewController.searchDrawer.searchBar.becomeFirstResponder()
        
    }
    
}