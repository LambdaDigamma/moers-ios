//
//  Container+ParkingService.swift
//  ParkingFeature
//
//  Created for Factory migration
//

import Foundation
import FactoryKit

public extension Container {
    
    @MainActor
    var parkingService: Factory<ParkingService> {
        self {
            StaticParkingService()
        }
    }
    
}
