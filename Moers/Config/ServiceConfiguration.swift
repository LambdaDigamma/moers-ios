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
import OSLog

#if canImport(RubbishFeature)
import RubbishFeature
#endif

#if canImport(FuelFeature)
import FuelFeature
#endif

#if canImport(ParkingFeature)
import ParkingFeature
import NewsFeature
#endif

public class ServiceConfiguration: BootstrappingProcedureStep {
    
    @LazyInjected var loader: HTTPLoader
    
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleID, category: "ServiceConfiguration")
    
    public func execute(with application: UIApplication) {
        
        #if DEBUG
        if LaunchArgumentsHandler.isSnapshotting() {
            return self.setupStatic()
        }
        #endif
        
        self.setup()
        
    }
    
    func executeInExtension() {
        return self.setup()
    }
    
    public func setup() {
        
        self.logger.info("Setting up default services.")
        
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
        
#if canImport(NewsFeature)
        let newsService = DefaultNewsService()
        Resolver.register { newsService as NewsService }
#endif
        
    }
    
    private func setupStatic() {
        self.logger.info("Setting up static services for testing/screenshotting.")
        
        CoreSettings.userDefaults = UserDefaults.appGroup
        UserDefaults.appGroup.set(true, forKey: "UserDidCompleteSetup")
        
        let locationService = StaticLocationService()
        let geocodingService = StaticGeocodingService(defaultPlacemark: CoreSettings.defaultPlacemark())
        
        Resolver.register { locationService as LocationService }
        Resolver.register { geocodingService as GeocodingService }
        
#if canImport(RubbishFeature)
        
        let street = RubbishCollectionStreet(
            id: 1,
            street: "Musterstraße",
            residualWaste: 1,
            organicWaste: 1,
            paperWaste: 1,
            yellowBag: 1,
            greenWaste: 1,
            sweeperDay: ""
        )
        
        let rubbishService = StaticRubbishService(
            rubbishStreet: street,
            isEnabled: true,
            remindersEnabled: true,
            reminderHour: 20,
            reminderMinute: 0
        )
        
        Resolver.register { rubbishService as RubbishService }
#endif
        
#if canImport(FuelFeature)
        let fuelService = StaticPetrolService(petrolType: .diesel)
        Resolver.register { fuelService as PetrolService }
#endif
        
#if canImport(ParkingFeature)
        let parkingService = StaticParkingService()
        Resolver.register { parkingService as ParkingService }
#endif
        
#if canImport(NewsFeature)
        let newsService = DefaultNewsService()
        Resolver.register { newsService as NewsService }
#endif
        
    }
    
}
