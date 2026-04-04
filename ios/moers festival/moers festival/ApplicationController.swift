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
    
    var tabBarController: TabBarController? { rootTabBarController }
    
    private let logger: Logger = Logger(.coreAppLifecycle)
    
    private var rootTabBarController: TabBarController?
    
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
        
        ApplicationServerConfiguration.baseURL = "https://moers.app/api/v1/festival/"
        
        EventPackageConfiguration.accentColor = UIColor(named: "AccentColor")!
        EventPackageConfiguration.onAccentColor = UIColor(named: "OnAccent")!
        
        Core.UIPackageConfiguration.accentColor = UIColor(named: "AccentColor")!
        Core.UIPackageConfiguration.onAccentColor = UIColor(named: "OnAccent")!
        
        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: Constants.wasLaunchedBefore)
        self.eventService = eventService
        self.locationManager = locationManager
        self.entryManager = entryManager
        self.trackerManager = trackerManager
        
//        self.setupNotificationCenter()
        
    }
    
    func rootViewController() -> UIViewController {
        let tabBarController = TabBarController(
            eventService: eventService,
            entryManager: entryManager,
            trackerManager: trackerManager
        )

        self.rootTabBarController = tabBarController

        return tabBarController

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
                    environment = ServerEnvironment(scheme: "http", host: customUrl, pathPrefix: "/api/v1/festival")
                } else if customUrl.contains("https://") {
                    customUrl = customUrl.replacingOccurrences(of: "https://", with: "")
                    environment = ServerEnvironment(scheme: "https", host: customUrl, pathPrefix: "/api/v1/festival")
                } else {
                    environment = ServerEnvironment(scheme: "https", host: customUrl, pathPrefix: "/api/v1/festival")
                }
                
            case "production":
                environment = .production

            case "staging":
                environment = .staging
                
            case "local":
                environment = .local
                
            default:
                environment = .production
        }
        
        return environment
        
    }
    
    nonisolated static func eventCache() -> Storage<String, [Event]> {
        
        return try! Storage<String, [Event]>(
            diskConfig: DiskConfig(name: "EventService"),
            memoryConfig: MemoryConfig(),
            fileManager: .default,
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
        self.tabBarController?.showWebpage(url: url)
        
    }
    
    // MARK: - Coordinator Handling -
    
    internal var currentNews: NewsCoordinator {
        guard let rootTabBarController else {
            fatalError("Root controller was not configured before resolving the news coordinator.")
        }
        return rootTabBarController.news
    }
    
    internal var currentLive: LiveCoordinator {
        guard let rootTabBarController else {
            fatalError("Root controller was not configured before resolving the live coordinator.")
        }
        return rootTabBarController.live
    }
    
    internal var currentMap: MapCoordinator {
        guard let rootTabBarController else {
            fatalError("Root controller was not configured before resolving the map coordinator.")
        }
        return rootTabBarController.map
    }
    
    internal var currentUserSchedule: UserScheduleCoordinator {
        guard let rootTabBarController else {
            fatalError("Root controller was not configured before resolving the user schedule coordinator.")
        }
        return rootTabBarController.userSchedule
    }
    
    internal var currentEvents: EventCoordinator {
        guard let rootTabBarController else {
            fatalError("Root controller was not configured before resolving the event coordinator.")
        }
        return rootTabBarController.event
    }
    
    internal var currentOther: OtherCoordinator {
        guard let rootTabBarController else {
            fatalError("Root controller was not configured before resolving the other coordinator.")
        }
        return rootTabBarController.other
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
        
        activateTopLevelDestination(.news)
        
    }
    
    public func openPostDetail(postID: Post.ID, animated: Bool = false) {
        
        currentNews.navigationController.popToRootViewController(animated: false)
        currentNews.navigationController.dismiss(animated: false)

        activateTopLevelDestination(.news)
        currentNews.showPost(postID: postID)
        
    }
    
    public func openMap(animated: Bool = false) {
        
        activateTopLevelDestination(.maps)
        
    }
    
    public func openUserSchedule(animated: Bool = false) {
        
        currentUserSchedule.navigationController.dismiss(animated: false)
        
        activateTopLevelDestination(.userSchedule)
        currentUserSchedule.showOverview(animated: false)
        
    }
    
    public func openEvents(animated: Bool = false) {
        
        currentEvents.navigationController.dismiss(animated: false)
        
        activateTopLevelDestination(.events)
        currentEvents.showOverview(animated: false)
        
    }
    
    public func openEventDetail(eventID: Event.ID, animated: Bool = false) {
        
        currentEvents.navigationController.dismiss(animated: false)

        activateTopLevelDestination(.events)
        currentEvents.showDetail(for: eventID, animated: animated)
        
    }
    
    public func openOther(animated: Bool = false) {
        
        currentOther.navigationController.popToRootViewController(animated: false)
        currentOther.navigationController.dismiss(animated: false)
        
        activateTopLevelDestination(.other)
        
    }
    
}

private extension ApplicationController {

    func activateTopLevelDestination(_ tabIndex: TabIndices) {
        rootTabBarController?.selectedIndex = tabIndex.rawValue
    }

}

extension Coordinator {
    
    public func showPage(url: URL) {
        
        DispatchQueue.main.async {
            
            let fallbackController = FallbackWebViewController(url: url)
            
            fallbackController.navigationItem.largeTitleDisplayMode = .never
            fallbackController.navigationCallback = { url in

                let nextController = FallbackWebViewController(url: url)
                nextController.navigationItem.largeTitleDisplayMode = .never
                nextController.navigationCallback = fallbackController.navigationCallback

                if UIDevice.current.userInterfaceIdiom == .pad,
                   let navigationController = fallbackController.navigationController {
                    navigationController.pushViewController(nextController, animated: true)
                } else {
                    self.showPage(url: url)
                }
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                let navigationController = UINavigationController(rootViewController: fallbackController)
                navigationController.modalPresentationStyle = .formSheet

                var presenter: UIViewController = self.rootViewController
                while let presented = presenter.presentedViewController {
                    presenter = presented
                }

                presenter.present(navigationController, animated: true)
            } else {
                self.resolvedNavigationController()?.pushViewController(fallbackController, animated: true)
            }
            
        }
        
    }
    
    private func resolvedNavigationController() -> UINavigationController? {
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController
        }
        
        return rootViewController.navigationController
    }
    
}
