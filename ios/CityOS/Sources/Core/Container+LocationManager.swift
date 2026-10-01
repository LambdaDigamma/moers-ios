//
//  Container+LocationManager.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import FactoryKit

public extension Container {
    
    @MainActor
    var locationManager: Factory<LocationManagerProtocol> {
        self {
            LocationManager()
        }
        .singleton
    }
    
}
