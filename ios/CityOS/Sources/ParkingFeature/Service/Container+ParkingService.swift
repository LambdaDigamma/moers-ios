//
//  Container+ParkingService.swift
//  ParkingFeature
//
//  Created for Factory migration
//

import Foundation
import Factory

public extension Container {
    
    var parkingService: Factory<ParkingService> {
        self {
            StaticParkingService()
        }
    }
    
}
