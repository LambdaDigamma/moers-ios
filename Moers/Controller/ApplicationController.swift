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

class ApplicationController: UIViewController {

    let loader: HTTPLoader
    
    let locationManager: LocationManagerProtocol
    let petrolManager: PetrolManagerProtocol
    let geocodingManager: GeocodingManagerProtocol
    let cameraManager: CameraManagerProtocol
    let entryManager: EntryManagerProtocol
    let parkingLotManager: ParkingLotManagerProtocol
    let eventService: EventServiceProtocol
    
    convenience init(loader: HTTPLoader) {
        self.init(loader: loader, entryManager: EntryManager(loader: loader))
    }
    
    init(
        loader: HTTPLoader,
        locationManager: LocationManagerProtocol = LocationManager(),
        petrolManager: PetrolManagerProtocol = PetrolManager(storageManager: StorageManager()),
        geocodingManager: GeocodingManagerProtocol = GeocodingManager(),
        cameraManager: CameraManagerProtocol = CameraManager(storageManager: StorageManager()),
        entryManager: EntryManagerProtocol,
        parkingLotManager: ParkingLotManagerProtocol = ParkingLotManager()
    ) {
        
        self.loader = loader
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
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: self)
        
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
        
        let tabBarController = TabBarController(
            locationManager: locationManager,
            petrolManager: petrolManager,
            geocodingManager: geocodingManager,
            cameraManager: cameraManager,
            entryManager: entryManager,
            parkingLotManager: parkingLotManager,
            eventService: eventService
        )
        
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = tabBarController
        
    }

}

extension ApplicationController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: ApplicationTheme) {
        
        self.view.backgroundColor = theme.backgroundColor
        
    }
    
}
