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
import Factory
import EFAAPI

#if canImport(RubbishFeature)
import RubbishFeature
#endif

#if canImport(FuelFeature)
import FuelFeature
#endif

#if canImport(ParkingFeature)
import ParkingFeature
import NewsFeature
import Cache
//import MMEvents
#endif

import MMEvents
import MapFeature

public class ServiceConfiguration: BootstrappingProcedureStep {
    
    private var loader: HTTPLoader = Resolver.resolve()
    
    private let logger: Logger = Logger(.coreAppConfig)
    
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
        
        Container.shared.geocodingService.register { geocodingService as GeocodingService }
        
        let locationManager = LocationManager()
        Resolver.register { locationManager as LocationManagerProtocol }
        
        let entryManager = EntryManager(loader: loader)
        Resolver.register { entryManager as EntryManagerProtocol }
        
//        let storageManager = StorageManager<Camera>()
        let cameraService = CameraManager(/*storageManager: Moers.StorageManager()*/)
        Resolver.register { cameraService as CameraManagerProtocol }
        
#if canImport(RubbishFeature)
        let rubbishService = DefaultRubbishService(loader: loader, userDefaults: UserDefaults.appGroup)
        Resolver.register { rubbishService as RubbishService }
#endif
        
#if canImport(FuelFeature)
        let petrolService = DefaultPetrolService(
            userDefaults: UserDefaults.appGroup,
            apiKey: loadFuelApiKey()
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
        
#if canImport(MMEvents)
        let cache = try! Cache.Storage<String, [Event]>(
            diskConfig: Cache.DiskConfig(name: "EventService"),
            memoryConfig: Cache.MemoryConfig(),
            transformer: Cache.TransformerFactory.forCodable(ofType: [Event].self)
        )

        let eventService = DefaultEventService(loader)

        Resolver.register { eventService as EventService }
#endif
        
        Container.shared.transitService.register {
            DefaultTransitService(loader: DefaultTransitService.defaultLoader())
        }
        
        Container.shared.tripService.register {
            DefaultTripService()
        }
        
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
        let newsService = StaticNewsService()
        Resolver.register { newsService as NewsService }
#endif
        
    }
    
    private func loadFuelApiKey() -> String {
        
        guard let filePath = Bundle.main.path(forResource: "Tankerkoenig-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Tankerkoenig-Info.plist'.")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'Tankerkoenig-Info.plist'.")
        }
        
        if (value.starts(with: "_")) {
            fatalError("Register for a Tankerkoenig account and get an API key at https://creativecommons.tankerkoenig.de.")
        }
        return value
    }
    
}
