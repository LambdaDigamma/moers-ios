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

        MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: self)
        
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

extension ApplicationController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: ApplicationTheme) {
        UIApplication.shared.statusBarStyle = theme.statusBarStyle
        self.view.backgroundColor = theme.backgroundColor
    }
    
}
