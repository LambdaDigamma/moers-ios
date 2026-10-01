//
//  Container+PetrolService.swift
//  FuelFeature
//
//  Created for Factory migration
//

import Foundation
import FactoryKit

public extension Container {
    
    @MainActor
    var petrolService: Factory<PetrolService> {
        self {
            StaticPetrolService()
        }
    }
    
}
