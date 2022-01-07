//
//  ApplicationController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI
import MMAPI
import MarkdownKit
import SwiftyMarkdown
import ModernNetworking
import MMEvents
import Cache
import Resolver

class ApplicationController: NSObject {

    @LazyInjected var loader: HTTPLoader
    
    let locationManager: LocationManagerProtocol
    let petrolManager: PetrolManagerProtocol
    let geocodingManager: GeocodingManagerProtocol
    let cameraManager: CameraManagerProtocol
    let entryManager: EntryManagerProtocol
    let parkingLotManager: ParkingLotManagerProtocol
    let eventService: EventServiceProtocol
    
    var tabController: TabBarController!
    
    convenience override init() {
        let loader: HTTPLoader = Resolver.resolve()
        self.init(entryManager: EntryManager(loader: loader))
    }
    
    init(
        locationManager: LocationManagerProtocol = LocationManager(),
        petrolManager: PetrolManagerProtocol = PetrolManager(storageManager: StorageManager()),
        geocodingManager: GeocodingManagerProtocol = GeocodingManager(),
        cameraManager: CameraManagerProtocol = CameraManager(storageManager: StorageManager()),
        entryManager: EntryManagerProtocol,
        parkingLotManager: ParkingLotManagerProtocol = ParkingLotManager()
    ) {
        
        let loader: HTTPLoader = Resolver.resolve()
        
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.geocodingManager = geocodingManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        self.parkingLotManager = parkingLotManager
        
        // swiftlint:disable:next force_try
        let cache = try! Storage<String, [MMEvents.Event]>(
            diskConfig: DiskConfig(name: "EventService"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: [MMEvents.Event].self)
        )
        
        self.eventService = EventService(loader, cache)
        
        super.init()
        
        MMUIConfig.markdownConverter = { text in
            
            let markdown = SwiftyMarkdown(string: text)
            
            markdown.setFontColorForAllStyles(with: UIColor.white)
            markdown.h1.fontStyle = FontStyle.bold
            markdown.h2.fontStyle = FontStyle.bold
            markdown.h3.fontStyle = FontStyle.boldItalic
            markdown.link.color = UIColor.systemYellow
            markdown.underlineLinks = false
            markdown.bullet = "•"
            
            return markdown.attributedString()
            
        }
        
    }
    
    // MARK: -
    
    internal func rootViewController() -> UIViewController {
        
        self.tabController = TabBarController(
            locationManager: locationManager,
            petrolManager: petrolManager,
            geocodingManager: geocodingManager,
            cameraManager: cameraManager,
            entryManager: entryManager,
            parkingLotManager: parkingLotManager,
            eventService: eventService
        )
        
        let splitViewController = SplitController(tabController: tabController)
        let sidebarController = SidebarViewController()
        
        splitViewController.setViewController(tabController, for: .compact)
        splitViewController.setViewController(sidebarController, for: .primary)
        splitViewController.setViewController(tabController, for: .secondary)
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.presentsWithGesture = false
        splitViewController.preferredSplitBehavior = .tile
        splitViewController.primaryBackgroundStyle = .sidebar
        splitViewController.showsSecondaryOnlyButton = true
        splitViewController.presentsWithGesture = true
        
        if #available(iOS 14.5, *) {
            splitViewController.displayModeButtonVisibility = .always
        }
        
        return splitViewController
        
    }
    
}
