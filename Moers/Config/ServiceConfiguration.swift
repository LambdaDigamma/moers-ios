//
//  ServiceConfiguration.swift
//  Moers
//
//  Created by Lennart Fischer on 05.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit
import AppScaffold
import Resolver
import ModernNetworking
import Core

#if canImport(RubbishFeature)
import RubbishFeature
#endif

#if canImport(FuelFeature)
import FuelFeature
#endif

#if canImport(ParkingFeature)
import ParkingFeature
#endif

public class ServiceConfiguration: BootstrappingProcedureStep {
    
    @LazyInjected var loader: HTTPLoader
    
    public func execute(with application: UIApplication) {
        self.setup()
    }
    
    func executeInExtension() {
        return self.setup()
    }
    
    public func setup() {
        
        CoreSettings.userDefaults = UserDefaults.appGroup
        
        let locationService = DefaultLocationService()
        let geocodingService = DefaultGeocodingService()
        
        Resolver.register { locationService as LocationService }
        Resolver.register { geocodingService as GeocodingService }
        
        #if canImport(RubbishFeature)
        let rubbishService = DefaultRubbishService(loader: loader, userDefaults: UserDefaults.appGroup)
        Resolver.register { rubbishService as RubbishService }
        #endif
        
        #if canImport(FuelFeature)
        let petrolService = DefaultPetrolService(
            userDefaults: UserDefaults.appGroup,
            apiKey: "0dfdfad3-7385-ef47-2ff6-ec0477872677"
        )
        Resolver.register { petrolService as PetrolService }
        #endif
        
        #if canImport(ParkingFeature)
        let parkingService = DefaultParkingService(loader: loader)
        Resolver.register { parkingService as ParkingService }
        #endif
        
    }
    
}
