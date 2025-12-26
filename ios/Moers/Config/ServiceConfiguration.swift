//
//  ServiceConfiguration.swift
//  Moers
//
//  Created by Lennart Fischer on 05.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit
import AppScaffold
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
    
    @Injected(\.httpLoader) private var loader: HTTPLoader
    
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
        
        Container.shared.locationService.register { locationService }
        Container.shared.geocodingService.register { geocodingService }
        
        let locationManager = LocationManager()
        Container.shared.locationManager.register { locationManager }
        
        let entryManager = EntryManager(loader: loader)
        Container.shared.entryManager.register { entryManager }
        
//        let storageManager = StorageManager<Camera>()
        let cameraService = CameraManager(/*storageManager: Moers.StorageManager()*/)
        Container.shared.cameraManager.register { cameraService }
        
#if canImport(RubbishFeature)
        let rubbishService = DefaultRubbishService(loader: loader, userDefaults: UserDefaults.appGroup)
        Container.shared.rubbishService.register { rubbishService }
#endif
        
#if canImport(FuelFeature)
        let petrolService = DefaultPetrolService(
            userDefaults: UserDefaults.appGroup,
            apiKey: loadFuelApiKey()
        )
        Container.shared.petrolService.register { petrolService }
#endif
        
#if canImport(ParkingFeature)
        let parkingService = DefaultParkingService(loader: loader)
        Container.shared.parkingService.register { parkingService }
#endif
        
#if canImport(NewsFeature)
        let newsService = DefaultNewsService()
        Container.shared.newsService.register { newsService }
#endif
        
#if canImport(MMEvents)
        
        let eventService = DefaultEventService(loader)

        Container.shared.eventService.register { eventService }
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
        
        Container.shared.locationService.register { locationService }
        Container.shared.geocodingService.register { geocodingService }
        
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
        
        Container.shared.rubbishService.register { rubbishService }
#endif
        
#if canImport(FuelFeature)
        let fuelService = StaticPetrolService(petrolType: .diesel)
        Container.shared.petrolService.register { fuelService }
#endif
        
#if canImport(ParkingFeature)
        let parkingService = StaticParkingService()
        Container.shared.parkingService.register { parkingService }
#endif
        
#if canImport(NewsFeature)
        let newsService = StaticNewsService()
        Container.shared.newsService.register { newsService }
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
