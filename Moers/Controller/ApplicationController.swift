//
//  ApplicationController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI
import MMAPI

extension EntryManager: EntryManagerProtocol {}

class ApplicationController: UIViewController {

    let locationManager: LocationManagerProtocol
    let petrolManager: PetrolManagerProtocol
    let rubbishManager: RubbishManagerProtocol
    let geocodingManager: GeocodingManagerProtocol
    let cameraManager: CameraManagerProtocol
    let entryManager: EntryManagerProtocol
    let parkingLotManager: ParkingLotManagerProtocol
    
    init(locationManager: LocationManagerProtocol = LocationManager(),
         petrolManager: PetrolManagerProtocol = PetrolManager(),
         rubbishManager: RubbishManagerProtocol = RubbishManager(),
         geocodingManager: GeocodingManagerProtocol = GeocodingManager(),
         cameraManager: CameraManagerProtocol = CameraManager(),
         entryManager: EntryManagerProtocol = EntryManager(),
         parkingLotManager: ParkingLotManagerProtocol = ParkingLotManager()) {
        
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.rubbishManager = rubbishManager
        self.geocodingManager = geocodingManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        self.parkingLotManager = parkingLotManager
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            UIApplication.shared.statusBarStyle = theme.statusBarStyle
            themeable.view.backgroundColor = theme.backgroundColor
        }
        
        let tabBarController = TabBarController(locationManager: locationManager,
                                                petrolManager: petrolManager,
                                                rubbishManager: rubbishManager,
                                                geocodingManager: geocodingManager,
                                                cameraManager: cameraManager,
                                                entryManager: entryManager,
                                                parkingLotManager: parkingLotManager)
        
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = tabBarController
        
    }

}
