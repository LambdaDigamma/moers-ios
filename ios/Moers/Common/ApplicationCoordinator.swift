//
//  ApplicationController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import AppScaffold
import UIKit
import ModernNetworking
import Events
import Cache
import FactoryKit
import OSLog
import Core
import EFAUI
import MapFeature

@MainActor
class ApplicationCoordinator: NSObject {

    @Injected(\.httpLoader) var loader: HTTPLoader
    
    private let logger: Logger = Logger(.coreAppLifecycle)
    
    let firstLaunch: FirstLaunch
    
    let locationManager: LocationManagerProtocol
    let cameraManager: CameraManagerProtocol
    
    private lazy var tabBarController = AppTabBarController(firstLaunch: firstLaunch)
    
    convenience override init() {
        @Injected(\.httpLoader) var loader: HTTPLoader
        @Injected(\.entryManager) var entryManager: EntryManagerProtocol
        self.init(entryManager: entryManager)
    }
    
    init(
        locationManager: LocationManagerProtocol = LocationManager(),
        cameraManager: CameraManagerProtocol = CameraManager(storageManager: StorageManager()),
        entryManager: EntryManagerProtocol
    ) {
        
        self.firstLaunch = FirstLaunch(userDefaults: .appGroup, key: Constants.firstLaunch)
        
        self.locationManager = locationManager
        self.cameraManager = cameraManager
        
        super.init()
        
//        UIConfig.markdownConverter = { text in
//
//            let markdown = SwiftyMarkdown(string: text)
//
//            markdown.setFontColorForAllStyles(with: UIColor.white)
//            markdown.h1.fontStyle = FontStyle.bold
//            markdown.h2.fontStyle = FontStyle.bold
//            markdown.h3.fontStyle = FontStyle.boldItalic
//            markdown.link.color = UIColor.systemYellow
//            markdown.underlineLinks = false
//            markdown.bullet = "•"
//
//            return markdown.attributedString()
//
//        }
        
    }
    
    // MARK: - View Controller Handling -
    
    internal func rootViewController() -> UIViewController {
        
        return tabBarController
        
    }
    
    // MARK: - Navigation -
    
    internal func handle(userActivity: NSUserActivity) {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            self.handleUniversalLinks(from: userActivity)
        }
        
        self.handleStateRestoration(userActivity: userActivity)
        
    }
    
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
            return openNewsOverview()
        }
        
        if path.containsPathElement("events", "veranstaltungen") {
            return openEventsOverview()
        }
        
        if path.containsPathElement("settings", "einstellungen") {
            return openSettings()
        }
        
        if path.containsPathElement("bürgerfunk", "buergerfunk") {
            return openBuergerfunk()
        }
        
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    internal func handleStateRestoration(userActivity: NSUserActivity) {
        
        switch userActivity.activityType {
            case UserActivities.IDs.dashboard:
                openDashboard()
            case UserActivities.IDs.rubbishSchedule, WidgetKinds.rubbish.rawValue:
                openRubbishScheduleDetails()
            case UserActivities.IDs.fuelStations:
                openFuelStationList()
            case UserActivities.IDs.newsOverview:
                openNewsOverview()
            case UserActivities.IDs.map:
                openMap()
            case UserActivities.IDs.events:
                openEventsOverview()
            case UserActivities.IDs.other:
                openOther()
            case UserActivities.IDs.settings:
                openSettings()
            case TransportationUserActivity.IDs.transportationOverview:
                openTransportationOverview()
            case TransportationUserActivity.IDs.search:
                handleTransportationSearch(with: userActivity)
            default:
                logger.error("Application was not able to handle user activity.")
        }
        
    }
    
    internal var currentDashboard: DashboardCoordinator {
        return tabBarController.dashboard
    }
    
    internal var currentNews: NewsCoordinator {
        return tabBarController.news
    }
    
    internal var currentMap: MapCoordintor {
        return tabBarController.map
    }
    
    internal var currentEvents: EventCoordinator {
        return tabBarController.events
    }
    
    internal var currentOther: OtherCoordinator {
        return tabBarController.other
    }
    
    // MARK: - Actions -
    
    public func openDashboard(animated: Bool = false) {
        
        tabBarController.selectedIndex = TabIndices.dashboard.rawValue

        currentDashboard.navigationController.popToRootViewController(animated: false)
        
    }
    
    public func openRubbishScheduleDetails() {
        
        openDashboard()
        currentDashboard.pushRubbishViewController()
        
    }
    
    public func openFuelStationList() {
        
        openDashboard()
        currentDashboard.pushFuelStationListViewController()
        
    }
    
    public func openNewsOverview(animated: Bool = false) {
        
        tabBarController.selectedIndex = TabIndices.news.rawValue
        
        currentNews.navigationController.popToRootViewController(animated: animated)
        
    }
    
    public func openNewsArticle(url: URL) {
        
        openNewsOverview()
        currentNews.open(url: url)
        
    }
    
    public func openMap(animated: Bool = false) {
        
        tabBarController.selectedIndex = TabIndices.maps.rawValue
        
        currentMap.navigationController.popToRootViewController(animated: animated)
        
    }
    
    public func openEventsOverview(animated: Bool = false) {
        
        tabBarController.selectedIndex = TabIndices.events.rawValue
        
        currentEvents.navigationController.popToRootViewController(animated: animated)
        
    }
    
    private func openOther(animated: Bool = false) {
        
        tabBarController.selectedIndex = TabIndices.other.rawValue
        
        currentOther.navigationController.popToRootViewController(animated: animated)
        
    }
    
    private func openSettings(animated: Bool = false) {
        
        openOther(animated: animated)
        currentOther.showSettings()
        
    }
    
    private func openBuergerfunk(animated: Bool = false) {
        
        openOther(animated: animated)
        currentOther.showBuergerfunk()
        
    }
    
    private func openTransportationOverview(animated: Bool = false) {
        
        openOther(animated: animated)
        currentOther.showTransportationOverview()
        
    }
    
    private func openTransportationSearch(data: TripSearchActivityData? = nil, animated: Bool = false) {
        
        openOther(animated: animated)
        currentOther.showTransporationSearch(data: data)
        
    }
    
    private func handleTransportationSearch(with userActivity: NSUserActivity) {
        
        do {
            
            let data = try userActivity.typedPayload(TripSearchActivityData.self)
            
            openTransportationSearch(data: data, animated: false)
            
        } catch let error as DecodingError {
            logger.error("Failed decoding typed payload handling transpoartion search: \(error.errorDescription ?? "", privacy: .public)")
        } catch {
            logger.error("Failed decoding typed payload handling transpoartion search: \(error.localizedDescription, privacy: .public)")
        }
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
