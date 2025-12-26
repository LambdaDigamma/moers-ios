//
//  Container+PetrolService.swift
//  FuelFeature
//
//  Created for Factory migration
//

import Foundation
import Factory

public extension Container {
    
    var petrolService: Factory<PetrolService> {
        self {
            StaticPetrolService()
        }
    }
    
}
