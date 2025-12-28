//
//  ApplicationController.swift
//  moers festival
//
//  Created by Lennart Fischer on 14.12.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import Core
import UIKit
import OSLog
import Cache
import ModernNetworking
import BLTNBoard
import AppScaffold
import Combine
import MMEvents
import MMFeeds
import Factory

class ApplicationController: NSObject, ApplicationControlling {
    
    var firstLaunch: FirstLaunch
    var config: AppConfigurable = AppConfiguration(minVersion: "1.0.0", structure: nil)
    
    private let locationManager: LocationManager
    private let eventService: LegacyEventService
    private let entryManager: EntryManagerProtocol
    private let trackerManager: TrackerManagerProtocol
    
    var tabBarController: TabBarController? {
        splitViewController.tabController
    }
    
    private let logger: Logger = Logger(.coreAppLifecycle)
    
    private var splitViewController: AppSplitViewController!
    
    var cancellables = Set<AnyCancellable>()
    
    public init(
        locationManager: LocationManager = LocationManager(),
        eventService: LegacyEventService = DefaultLegacyEventService(
            Container.shared.httpLoader(),
            ApplicationController.eventCache()
        ),
        entryManager: EntryManagerProtocol = EntryManager(loader: Container.shared.httpLoader()),
        trackerManager: TrackerManagerProtocol = TrackerManager(storageManager: StorageManager())
    ) {
        
        ApplicationServerConfiguration.baseURL = "https://archiv.moers-festival.de/api/v1/"
        
        EventPackageConfiguration.accentColor = UIColor(named: "AccentColor")!
        EventPackageConfiguration.onAccentColor = UIColor(named: "OnAccent")!
        
        Core.UIPackageConfiguration.accentColor = UIColor(named: "AccentColor")!
        Core.UIPackageConfiguration.onAccentColor = UIColor(named: "OnAccent")!
        
        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: Constants.wasLaunchedBefore)
        self.eventService = eventService
        self.locationManager = locationManager
        self.entryManager = entryManager
        self.trackerManager = trackerManager
        
//        let configurationURL = URL(string: "https://s3.eu-central-1.amazonaws.com/com.donnywals.blog/config.json")!
//
//        let configProvider = ConfigurationProvider<AppConfiguration>(
//            remoteLoader: DefaultRemoteConfigurationLoader(configurationURL: configurationURL),
//            localLoader: DefaultLocalConfigurationLoader()
//        )
//
//        configProvider.updateConfiguration()
        
//        let config = DefaultLocalConfigurationLoader<AppConfiguration>().defaultConfig
        
//        configProvider.$configuration.sink { newConfig in
//
//            print("Configuration")
//            print(newConfig)
//
//        }
//        .store(in: &cancellables)
    
//        self.setupNotificationCenter()
        
    }
    
    func rootViewController() -> UIViewController {
        
        self.splitViewController = AppSplitViewController(
            firstLaunch: firstLaunch,
            eventService: eventService,
            entryManager: entryManager,
            trackerManager: trackerManager
        )
        
        return splitViewController
        
    }

    static func loadServerEnvironment() -> ServerEnvironment {
        
        var settingsEnvironment = "production"
        
#if DEBUG
        settingsEnvironment = UserDefaults.standard.string(forKey: "environment") ?? "production"
#endif
        
        let environment: ServerEnvironment
        
        switch settingsEnvironment {
            case "custom":
                
                var customUrl = UserDefaults.standard.string(forKey: "customUrlTextField") ?? ""
                
                if customUrl.contains("http://") {
                    customUrl = customUrl.replacingOccurrences(of: "http://", with: "")
                    environment = ServerEnvironment(scheme: "http", host: customUrl, pathPrefix: "/api/v1")
                } else if customUrl.contains("https://") {
                    customUrl = customUrl.replacingOccurrences(of: "https://", with: "")
                    environment = ServerEnvironment(scheme: "https", host: customUrl, pathPrefix: "/api/v1")
                } else {
                    environment = ServerEnvironment(scheme: "https", host: customUrl, pathPrefix: "/api/v1")
                }
                
            case "production":
                environment = .production
                
            case "local":
                environment = .local
                
            default:
                environment = .production
        }
        
        return environment
        
    }
    
    static func eventCache() -> Storage<String, [Event]> {
        
        return try! Storage<String, [Event]>(
            diskConfig: DiskConfig(name: "EventService"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: [Event].self)
        )
        
    }
    
    internal func handle(userActivity: NSUserActivity) {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            self.handleUniversalLinks(from: userActivity)
        }
        
    }
    
    internal func handleUniversalLinks(from userActivity: NSUserActivity) {
        
        logger.info("Trying to handle universal link.")
        
        guard let url = userActivity.webpageURL,
              let _ = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        logger.info("Handling universal link: \(url.absoluteString)")
        
        let path = url.pathComponents
        
        if path.containsPathElement("live") {
            return openLive()
        }
        
        if path.containsPathElement("news", "neuigkeiten") {
            return openNews()
        }
        
        if path.containsPathElement("map", "spielorte", "venues") {
            return openMap()
        }
        
        if path.containsPathElement("events", "spielplan", "schedule", "veranstaltungen") {
            return openEvents()
        }
        
//        if path.containsPathElement("festival22/e/") {
//
//            let eventPart = path.split(separator: "/e/").last
//
//        }
        
        self.openOther()
        self.splitViewController.tabController.showWebpage(url: url)
        
    }
    
    // MARK: - Coordinator Handling -
    
    internal var currentNews: NewsCoordinator {
        return splitViewController.displayCompact
        ? splitViewController.tabController.news
        : splitViewController.news
    }
    
    internal var currentLive: LiveCoordinator {
        return splitViewController.displayCompact
        ? splitViewController.tabController.live
        : splitViewController.live
    }
    
    internal var currentMap: MapCoordinator {
        return splitViewController.displayCompact
        ? splitViewController.tabController.map
        : splitViewController.map
    }
    
    internal var currentUserSchedule: UserScheduleCoordinator {
        return splitViewController.displayCompact
        ? splitViewController.tabController.userSchedule
        : splitViewController.tabController.userSchedule // todo: fix this and add user schedule to sidebar
    }
    
    internal var currentEvents: EventCoordinator {
        return splitViewController.displayCompact
        ? splitViewController.tabController.event
        : splitViewController.event
    }
    
    internal var currentOther: OtherCoordinator {
        return splitViewController.displayCompact
        ? splitViewController.tabController.other
        : splitViewController.other
    }
    
    // MARK: - Actions -
    
    public func openLive(animated: Bool = false) {
        
//        if splitViewController.displayCompact {
//            splitViewController.tabController.selectedIndex = TabIndices.live.rawValue
//        } else {
//            splitViewController.selectSidebarItem(.live)
//        }
//        
//        currentLive.navigationController.popToRootViewController(animated: false)
        
    }
    
    public func openNews(animated: Bool = false) {
        
        currentNews.navigationController.popToRootViewController(animated: false)
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.news.rawValue
        } else {
            splitViewController.selectSidebarItem(.news)
        }
        
    }
    
    public func openPostDetail(postID: Post.ID, animated: Bool = false) {
        
        currentNews.navigationController.popToRootViewController(animated: false)
        currentNews.navigationController.dismiss(animated: false)
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.news.rawValue
            splitViewController.tabController.news.showPost(postID: postID)
        } else {
            splitViewController.selectSidebarItem(.news)
            splitViewController.news.showPost(postID: postID)
        }
        
    }
    
    public func openMap(animated: Bool = false) {
        
        currentMap.navigationController.popToRootViewController(animated: false)
        currentMap.navigationController.dismiss(animated: false)
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.maps.rawValue
        } else {
            splitViewController.selectSidebarItem(.map)
        }
        
    }
    
    public func openUserSchedule(animated: Bool = false) {
        
        currentUserSchedule.navigationController.popToRootViewController(animated: false)
        currentUserSchedule.navigationController.dismiss(animated: false)
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.userSchedule.rawValue
        } else {
//            splitViewController.selectSidebarItem(.map)
        }
        
    }
    
    public func openEvents(animated: Bool = false) {
        
        currentEvents.navigationController.popToRootViewController(animated: false)
        currentEvents.navigationController.dismiss(animated: false)
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.events.rawValue
        } else {
            splitViewController.selectSidebarItem(.events)
        }
        
    }
    
    public func openEventDetail(eventID: Event.ID, animated: Bool = false) {
        
        currentEvents.navigationController.popToRootViewController(animated: false)
        currentEvents.navigationController.dismiss(animated: false)
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.events.rawValue
            splitViewController.tabController.event.pushEventDetail(eventID: eventID, animated: animated)
        } else {
            splitViewController.selectSidebarItem(.events)
            splitViewController.event.pushEventDetail(eventID: eventID, animated: animated)
        }
        
    }
    
    public func openOther(animated: Bool = false) {
        
        currentOther.navigationController.popToRootViewController(animated: false)
        currentOther.navigationController.dismiss(animated: false)
        
        if splitViewController.displayCompact {
            splitViewController.tabController.selectedIndex = TabIndices.other.rawValue
        } else {
            splitViewController.selectSidebarItem(.other)
        }
        
    }
    
}

extension Coordinator {
    
    public func showPage(url: URL) {
        
        DispatchQueue.main.async {
            
            let fallbackController = FallbackWebViewController(url: url)
            
            fallbackController.navigationItem.largeTitleDisplayMode = .never
            fallbackController.navigationCallback = { url in
                
                self.showPage(url: url)
                
            }
            
            self.navigationController.pushViewController(fallbackController, animated: true)
            
        }
        
    }
    
}
