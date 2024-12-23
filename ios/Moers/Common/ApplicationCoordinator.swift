//
//  ApplicationController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import AppScaffold
import UIKit
import Gestalt
import ModernNetworking
import MMEvents
import Cache
import Resolver
import OSLog
import Core
import EFAUI
import MapFeature

public enum TabIndices: Int {
    
    case dashboard = 0
    case news = 1
    case maps = 2
    case events = 3
    case other = 4
    
}

class ApplicationCoordinator: NSObject {

    @LazyInjected var loader: HTTPLoader
    
    private let logger: Logger = Logger(.coreAppLifecycle)
    
    let firstLaunch: FirstLaunch
    
    let locationManager: LocationManagerProtocol
    let cameraManager: CameraManagerProtocol
    
    private var splitViewController: AppSplitViewController!
    
    convenience override init() {
        let loader: HTTPLoader = Resolver.resolve()
        self.init(entryManager: EntryManager(loader: loader))
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
        
//        MMUIConfig.markdownConverter = { text in
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
        
        self.splitViewController = AppSplitViewController(
            firstLaunch: firstLaunch,
            locationManager: locationManager,
            cameraManager: cameraManager
        )
        
        // Restoring the user interface based on the current user activity
        splitViewController.onChangeTraitCollection = { _ in
            if let activity = UserActivity.current {
                self.logger.info("Changing trait collection and restoring \(activity.activityType)")
                self.handle(userActivity: activity)
            }
        }
        
        return splitViewController
        
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
        return splitViewController.displayCompact
            ? splitViewController.tabController.dashboard
            : splitViewController.dashboard
    }
    
    internal var currentNews: NewsCoordinator {
        return splitViewController.displayCompact
            ? splitViewController.tabController.news
            : splitViewController.news
    }
    
    internal var currentMap: MapCoordintor {
        return splitViewController.displayCompact
            ? splitViewController.tabController.map
            : splitViewController.map
    }
    
    internal var currentEvents: EventCoordinator {
        return splitViewController.displayCompact
            ? splitViewController.tabController.events
            : splitViewController.events
    }
    
    internal var currentOther: OtherCoordinator {
        return splitViewController.displayCompact
            ? splitViewController.tabController.other
            : splitViewController.other
    }
    
    // MARK: - Actions -
    
    public func openDashboard(animated: Bool = false) {
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.dashboard.rawValue
        } else {
            splitViewController.selectSidebarItem(.dashboard)
        }

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
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.news.rawValue
        } else {
            splitViewController.selectSidebarItem(.news)
        }
        
        currentNews.navigationController.popToRootViewController(animated: animated)
        
    }
    
    public func openNewsArticle(url: URL) {
        
        openNewsOverview()
        currentNews.open(url: url)
        
    }
    
    public func openMap(animated: Bool = false) {
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.maps.rawValue
        } else {
            splitViewController.selectSidebarItem(.map)
        }
        
        currentMap.navigationController.popToRootViewController(animated: animated)
        
    }
    
    public func openEventsOverview(animated: Bool = false) {
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.events.rawValue
        } else {
            splitViewController.selectSidebarItem(.events)
        }
        
        currentEvents.navigationController.popToRootViewController(animated: animated)
        
    }
    
    private func openOther(animated: Bool = false) {
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.other.rawValue
        } else {
            splitViewController.selectSidebarItem(.other)
        }
        
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
    
}
