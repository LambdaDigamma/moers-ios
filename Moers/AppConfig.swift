//
//  AppConfig.swift
//  Moers
//
//  Created by Lennart Fischer on 14.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import CoreLocation

struct AppConfig {
    
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    static let shared = AppConfig(name: "Moers", coordinate: CLLocationCoordinate2D(latitude: 51.451667, longitude: 6.626389))
    
}
