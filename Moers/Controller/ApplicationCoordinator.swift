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
import OSLog

public enum TabIndices: Int {
    
    case dashboard = 0
    case news = 1
    case maps = 2
    case events = 3
    case other = 4
    
}

class ApplicationCoordinator: NSObject {

    @LazyInjected var loader: HTTPLoader
    
    private let logger: Logger = Logger(.default)
    
    let firstLaunch: FirstLaunch
    
    let locationManager: LocationManagerProtocol
    let petrolManager: PetrolManagerProtocol
    let cameraManager: CameraManagerProtocol
    let entryManager: EntryManagerProtocol
    let parkingLotManager: ParkingLotManagerProtocol
    let eventService: EventServiceProtocol
    
    private var splitViewController: MainSplitViewController!
    
    convenience override init() {
        let loader: HTTPLoader = Resolver.resolve()
        self.init(entryManager: EntryManager(loader: loader))
    }
    
    init(
        locationManager: LocationManagerProtocol = LocationManager(),
        petrolManager: PetrolManagerProtocol = PetrolManager(storageManager: StorageManager()),
        cameraManager: CameraManagerProtocol = CameraManager(storageManager: StorageManager()),
        entryManager: EntryManagerProtocol,
        parkingLotManager: ParkingLotManagerProtocol = ParkingLotManager()
    ) {
        
        let loader: HTTPLoader = Resolver.resolve()
        
        self.firstLaunch = FirstLaunch(userDefaults: .appGroup, key: Constants.firstLaunch)
        
        self.locationManager = locationManager
        self.petrolManager = petrolManager
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
    
    // MARK: - View Controller Handling -
    
    internal func rootViewController() -> UIViewController {
        
        self.splitViewController = MainSplitViewController(
            firstLaunch: firstLaunch,
            locationManager: locationManager,
            petrolManager: petrolManager,
            cameraManager: cameraManager,
            entryManager: entryManager,
            parkingLotManager: parkingLotManager,
            eventService: eventService
        )
        
        return splitViewController
        
    }
    
    // MARK: - Navigation -
    
    internal func handleUniversalLinks(from userActivity: NSUserActivity) {
        
        logger.info("Trying to handle universal link.")
        
        guard let url = userActivity.webpageURL,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                  return
              }
        
        logger.info("Handling universal link: \(url.absoluteString)")
        
        if components.path.contains("/abfallkalender") {
            return openRubbishScheduleDetails()
        }
        
        let path = url.pathComponents
        
        if path.containsPathElement("tanken", "fuel") {
            return openFuelStationList()
        }
        
        if path.containsPathElement("news", "nachrichten") {
            return switchToNews()
        }
        
        if path.containsPathElement("events", "veranstaltungen") {
            return switchToEvents()
        }
        
        if path.containsPathElement("settings", "einstellungen") {
            return openSettings()
        }
        
        if path.containsPathElement("bürgerfunk", "buergerfunk") {
            return openBuergerfunk()
        }
        
    }
    
    public func openRubbishScheduleDetails() {
        splitViewController.switchToToday()
        splitViewController.tabController.selectedIndex = TabIndices.dashboard.rawValue
        splitViewController.tabController.dashboard.navigationController.popToRootViewController(animated: false)
        splitViewController.tabController.dashboard.pushRubbishViewController()
    }
    
    public func openFuelStationList() {
        splitViewController.tabController.selectedIndex = TabIndices.dashboard.rawValue
        splitViewController.tabController.navigationController?.popToRootViewController(animated: true)
        splitViewController.tabController.dashboard.pushFuelStationListViewController()
    }
    
    private func switchToNews() {
        splitViewController.tabController.news.navigationController.popToRootViewController(animated: true)
        splitViewController.tabController.selectedIndex = TabIndices.news.rawValue
    }
    
    private func switchToEvents() {
        splitViewController.tabController.events.navigationController.popToRootViewController(animated: true)
        splitViewController.tabController.selectedIndex = TabIndices.events.rawValue
    }
    
    private func openSettings() {
        splitViewController.tabController.selectedIndex = TabIndices.other.rawValue
        splitViewController.tabController.navigationController?.popToRootViewController(animated: true)
        splitViewController.tabController.other.showSettings()
    }
    
    private func openBuergerfunk() {
        splitViewController.tabController.selectedIndex = TabIndices.other.rawValue
        splitViewController.tabController.navigationController?.popToRootViewController(animated: true)
        splitViewController.tabController.other.showBuergerfunk()
    }
    
}
