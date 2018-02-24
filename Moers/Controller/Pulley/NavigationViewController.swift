//
//  NavigatioViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 04.11.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.shared.loadShop()
        API.shared.loadParkingLots()
        API.shared.loadCameras()
        API.shared.loadBikeChargingStations()
        
    }
    
}
