//
//  Container+LocationService.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import FactoryKit

public extension Container {
    
    @MainActor
    var locationService: Factory<LocationService> {
        self {
            DefaultLocationService()
        }
        .singleton
    }
    
}
