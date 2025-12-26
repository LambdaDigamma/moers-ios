//
//  Container+LocationManager.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import Factory

public extension Container {
    
    var locationManager: Factory<LocationManagerProtocol> {
        self {
            LocationManager()
        }
        .singleton
    }
    
}
