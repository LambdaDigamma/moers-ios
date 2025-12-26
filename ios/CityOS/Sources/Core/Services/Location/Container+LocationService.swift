//
//  Container+LocationService.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import Factory

public extension Container {
    
    var locationService: Factory<LocationService> {
        self {
            DefaultLocationService()
        }
        .singleton
    }
    
}
