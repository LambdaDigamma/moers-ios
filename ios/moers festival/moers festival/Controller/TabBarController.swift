//
//  TabBarViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 28.01.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import Core
import UIKit
import BLTNBoard
import CoreSpotlight
import UserNotifications
import CoreLocation
import Waxwing
import WhatsNewKit
import SwiftyMarkdown
import ModernNetworking
import AppScaffold
import WebKit
import SafariServices
import Combine
import MMEvents
import SwiftUI

public class TabBarController: UITabBarController, UITabBarControllerDelegate {

    let news: NewsCoordinator
    let live: LiveCoordinator
    let userSchedule: UserScheduleCoordinator
    let map: MapCoordinator
    let event: EventCoordinator
    let other: OtherCoordinator
    
    private let isMapEnabled = true
    private var cancellalbes = Set<AnyCancellable>()
    
    public var events: [Event] = []
    
    public init(
        eventService: LegacyEventService,
        entryManager: EntryManagerProtocol,
        trackerManager: TrackerManagerProtocol
    ) {
        
        self.news = NewsCoordinator()
        self.live = LiveCoordinator()
        self.userSchedule = UserScheduleCoordinator()
        self.map = MapCoordinator(
            eventService: eventService,
            entryManager: entryManager,
            trackerManager: trackerManager
        )
        self.event = EventCoordinator()
        self.other = OtherCoordinator()
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupNotificationCenter()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        self.viewControllers = [
            news.navigationController,
//            live.navigationController,
            map.navigationController,
            userSchedule.navigationController,
//            tour.navigationController,
            event.navigationController,
            other.navigationController
        ]
        
        MMUIConfig.markdownConverter = { text in
            
            let markdown = SwiftyMarkdown(string: text)

            markdown.setFontColorForAllStyles(with: UIColor.white)
            markdown.h1.fontStyle = FontStyle.bold
            markdown.h2.fontStyle = FontStyle.bold
            markdown.h3.fontStyle = FontStyle.boldItalic
            markdown.link.color = UIColor.yellow
            markdown.underlineLinks = false
            markdown.bullet = "•"
            
            return markdown.attributedString()
            
        }
        
        self.setupTheming()
        self.removeAllPendingNotifications()
//        self.testingNotifications()
        
        self.selectedIndex = 3
        
    }
    
    // MARK: - Public Methods
    
    public func handle(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let item = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            handle(shortcutItem: item)
        }
    }
    
    public func handle(shortcutItem: UIApplicationShortcutItem) {
        
        if shortcutItem.type == AppShortcuts.favorites {
            
            selectedViewController = userSchedule.navigationController
            event.showFavouriteEvents()
            
        } else if shortcutItem.type == AppShortcuts.events {
            
            selectedViewController = event.navigationController
            event.showNextEvents()
            
        } else if shortcutItem.type == AppShortcuts.news {
            
            selectedViewController = news.navigationController
            
        } else {
            fatalError("Unknown shortcut item type: \(shortcutItem.type).")
        }
        
    }
    
    public func handle(userActivity: NSUserActivity) {
        
        if userActivity.activityType == CSSearchableItemActionType {
            
            if let userInfo = userActivity.userInfo {
                
                guard let activityIdentifier = userInfo[CSSearchableItemActivityIdentifier] as? String else { return }
                
                if let identifier = activityIdentifier.components(separatedBy: ".").last, let id = Int(identifier) {
                    
                    self.selectedViewController = event.navigationController
                    self.event.showDetail(for: id)
                    
                }
                
            }
            
        } else if userActivity.activityType == "de.okfn.niederrhein.moers-festival.openNextEvents" {
            
            self.selectedViewController = event.navigationController
            self.event.showNextEvents()
            
        } else if userActivity.activityType == "de.okfn.niederrhein.moers-festival.openFavouriteEvents" {
            
            self.selectedViewController = event.navigationController
            self.event.showFavouriteEvents()
            
        } else if userActivity.activityType == "de.okfn.niederrhein.moers-festival.openEvent", let parameters = userActivity.userInfo as? [String: Int] {
            
            self.selectedViewController = event.navigationController
            
            if let id = parameters["id"] {
                
                self.event.showDetail(for: id)
                
            }
            
        }
        
        if let webUrl = userActivity.webpageURL {
            showWebpage(url: webUrl)
        }
        
    }
    
    // MARK: - Private Methods -
    
    private func setupTheming() {
        
        let viewControllers = [
            self.news.navigationController,
            self.live.navigationController,
            self.map.navigationController,
            self.event.navigationController,
            self.other.navigationController
        ]
        
        for nav in viewControllers {
            
            if #available(iOS 26.0, *) {
                
            } else {
                
                let barButtonAppearance = UIBarButtonItemAppearance(style: .plain)
                barButtonAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
                
                let barAppearance = UINavigationBarAppearance()
                barAppearance.configureWithDefaultBackground()
                barAppearance.backgroundColor = UIColor.systemBackground
                barAppearance.buttonAppearance = barButtonAppearance
                barAppearance.backButtonAppearance = barButtonAppearance
                barAppearance.doneButtonAppearance = barButtonAppearance
                
                nav.navigationBar.tintColor = UIColor.label
                nav.navigationBar.compactAppearance = barAppearance
                nav.navigationBar.standardAppearance = barAppearance
                nav.navigationBar.scrollEdgeAppearance = barAppearance
                nav.navigationBar.barTintColor = UIColor.label
                nav.navigationBar.prefersLargeTitles = true
                nav.navigationBar.barStyle = .black
                nav.navigationBar.isOpaque = false
                nav.navigationBar.isTranslucent = false
                nav.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
                nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
                
                UINavigationBar.appearance().standardAppearance = barAppearance
                UINavigationBar.appearance().compactAppearance = barAppearance
                
            }
            
        }
        
        if #available(iOS 26.0, *) {
            
            self.tabBar.tintColor = AppColors.navigationAccent
            
        } else {
            
            self.tabBar.barTintColor = UIColor.systemBackground
            self.tabBar.tintColor = AppColors.navigationAccent
            self.tabBar.barStyle = .black
            self.tabBar.isOpaque = false
            self.tabBar.isTranslucent = false
            
            self.tabBar.barStyle = .black
            
            let barAppearance = UIBarAppearance()
            barAppearance.configureWithDefaultBackground()
            barAppearance.backgroundColor = UIColor.systemBackground
            
            self.tabBar.standardAppearance = UITabBarAppearance(barAppearance: barAppearance)
            
            if #available(iOS 15.0, *) {
                self.tabBar.scrollEdgeAppearance = UITabBarAppearance(barAppearance: barAppearance)
            }
            
        }
        
    }
    
    private func setupNotificationCenter() {
        
        NotificationCenter.default.publisher(for: .DidReceiveRemoteConfig)
            .sink { (notification: Notification) in
                
                if self.isMapEnabled {
                    
//                    let isMapEnabled = ConfigManager.shared.isMapEnabled
//                    let numberOfVCs = self.viewControllers?.count ?? 0
//
//                    if numberOfVCs == 4 && !isMapEnabled {
//                        self.viewControllers?.remove(at: 1)
//                    } else if numberOfVCs == 3 && isMapEnabled {
//                        self.viewControllers?.insert(self.map.navigationController, at: 1)
//                    }
                    
                }
                
            }
            .store(in: &cancellalbes)
        
    }
    
    private func testingNotifications() {
        
        let center = CLLocationCoordinate2D(latitude: 51.4397, longitude: 6.6183)
        let regionEntry = CLCircularRegion(center: center, radius: 175.0, identifier: "Festival-Village-Entry")
        regionEntry.notifyOnEntry = true
        regionEntry.notifyOnExit = false
        
        let regionExit = CLCircularRegion(center: center, radius: 220.0, identifier: "Festival-Village-Exit")
        regionExit.notifyOnEntry = false
        regionExit.notifyOnExit = true
        
        let triggerEntry = UNLocationNotificationTrigger(region: regionEntry, repeats: true)
        let triggerExit = UNLocationNotificationTrigger(region: regionExit, repeats: true)
        
        let contentEntry = UNMutableNotificationContent()
        contentEntry.badge = nil
        contentEntry.title = String.localized("EntryTitle")
        contentEntry.body = String.localized("EntryBody")
        contentEntry.subtitle = String.localized("EntrySubtitle")
        
        let contentExit = UNMutableNotificationContent()
        contentExit.badge = nil
        contentExit.body = String.localized("ExitBody")
        contentExit.title = String.localized("ExitTitle")
        
        let exitRequest = UNNotificationRequest(identifier: "festival-village-exit", content: contentExit, trigger: triggerExit)
        let entryRequest = UNNotificationRequest(identifier: "festival-village-entry", content: contentEntry, trigger: triggerEntry)
        
        UNUserNotificationCenter.current().add(entryRequest) { (error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Successfully scheduled.")
            }
        }
            
        
        UNUserNotificationCenter.current().add(exitRequest) { (error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Successfully scheduled.")
            
            }
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
                print("\(requests.count) Pending Notification Requests")
            })
            
        }
        
    }
    
    private func removeAllPendingNotifications() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }
    
    internal func showWebpage(url: URL) {
        
        let fallbackController = FallbackWebViewController(url: url)
        
        fallbackController.navigationItem.largeTitleDisplayMode = .never
        fallbackController.navigationCallback = { url in
            
            self.showWebpage(url: url)
            
            print("callback")
            print(url)
        }
        
        self.other.navigationController.pushViewController(fallbackController, animated: true)
        
    }
    
}
