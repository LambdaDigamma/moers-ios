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
import AppUpdateFeature
import Factory

public class TabBarController: UITabBarController, UITabBarControllerDelegate, UIAdaptivePresentationControllerDelegate {

    let news: NewsCoordinator
    let live: LiveCoordinator
    let userSchedule: UserScheduleCoordinator
    let map: MapCoordinator
    let event: EventCoordinator
    let other: OtherCoordinator
    
    private let isMapEnabled = true
    private var cancellalbes = Set<AnyCancellable>()
    private let appUpdateController: AppUpdateController
    private var appUpdateBannerController: UIHostingController<AppUpdateBannerView>?
    private var appUpdateBannerHeightConstraint: NSLayoutConstraint?
    private var appUpdateSheetController: UIHostingController<AppUpdateSheetView>?
    
    public var events: [Event] = []
    
    public init(
        eventService: LegacyEventService,
        entryManager: EntryManagerProtocol,
        trackerManager: TrackerManagerProtocol
    ) {
        
        self.news = NewsCoordinator()
        self.live = LiveCoordinator()
        self.userSchedule = UserScheduleCoordinator()
        self.event = EventCoordinator()
        self.map = MapCoordinator(
            eventService: eventService,
            entryManager: entryManager,
            trackerManager: trackerManager,
            eventCoordinator: event
        )
        self.other = OtherCoordinator()
        self.appUpdateController = AppUpdateController(
            statusFetcher: AppStoreUpdateStatusFetcher(lookup: .appID("1341448683")),
            remoteConfigurationLoader: RemoteAppUpdateConfigurationService(loader: Container.shared.httpLoader.resolve()),
            fallbackStoreURL: URL(string: "itms-apps://itunes.apple.com/app/id1341448683")!
        )
        
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
        self.configureDisplayMode()
        
        self.viewControllers = [
            news.rootViewController,
//            live.navigationController,
            map.rootViewController,
            userSchedule.rootViewController,
//            tour.navigationController,
            event.rootViewController,
            other.rootViewController
        ]
        
        MMUIConfig.markdownConverter = { text in
            
            let markdown = SwiftyMarkdown(string: text)

            markdown.setFontColorForAllStyles(with: UIColor.white)
            markdown.h1.fontStyle = FontStyle.bold
            markdown.h2.fontStyle = FontStyle.bold
            markdown.h3.fontStyle = FontStyle.boldItalic
            markdown.link.color = AppColors.navigationAccent
            markdown.underlineLinks = false
            markdown.bullet = "•"
            
            return markdown.attributedString()
            
        }
        
        self.setupTheming()
        self.setupAppUpdateHandling()
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
            
            selectedViewController = userSchedule.rootViewController
            userSchedule.showOverview()
            
        } else if shortcutItem.type == AppShortcuts.events {
            
            selectedViewController = event.rootViewController
            event.showNextEvents()
            
        } else if shortcutItem.type == AppShortcuts.news {
            
            selectedViewController = news.rootViewController
            
        } else {
            fatalError("Unknown shortcut item type: \(shortcutItem.type).")
        }
        
    }
    
    public func handle(userActivity: NSUserActivity) {
        
        if userActivity.activityType == CSSearchableItemActionType {
            
            if let userInfo = userActivity.userInfo {
                
                guard let activityIdentifier = userInfo[CSSearchableItemActivityIdentifier] as? String else { return }
                
                if let identifier = activityIdentifier.components(separatedBy: ".").last, let id = Int(identifier) {
                    
                    self.selectedViewController = event.rootViewController
                    self.event.showDetail(for: id)
                    
                }
                
            }
            
        } else if userActivity.activityType == "de.okfn.niederrhein.moers-festival.openNextEvents" {
            
            self.selectedViewController = event.rootViewController
            self.event.showNextEvents()
            
        } else if userActivity.activityType == "de.okfn.niederrhein.moers-festival.openFavouriteEvents" {
            
            self.selectedViewController = userSchedule.rootViewController
            self.userSchedule.showOverview()
            
        } else if userActivity.activityType == "de.okfn.niederrhein.moers-festival.openEvent", let parameters = userActivity.userInfo as? [String: Int] {
            
            self.selectedViewController = event.rootViewController
            
            if let id = parameters["id"] {
                
                self.event.showDetail(for: id)
                
            }
            
        }
        
        if let webUrl = userActivity.webpageURL {
            showWebpage(url: webUrl)
        }
        
    }

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        dismissMapPresentationIfNeeded(beforeSelecting: viewController)
        return true
    }
    
    // MARK: - Private Methods -

    private func configureDisplayMode() {
        guard #available(iOS 18.0, *), traitCollection.userInterfaceIdiom == .pad else {
            return
        }

        self.mode = .tabBar
    }
    
    private func setupTheming() {
        
        let viewControllers = [
            self.news.navigationController,
            self.live.navigationController,
            self.userSchedule.navigationController,
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
                nav.navigationBar.isTranslucent = true
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
            self.tabBar.isTranslucent = true
            
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

    private func setupAppUpdateHandling() {
        appUpdateController.$banner
            .receive(on: DispatchQueue.main)
            .sink { [weak self] presentation in
                self?.updateAppUpdateBanner(presentation)
            }
            .store(in: &cancellalbes)

        appUpdateController.$forcedSheet
            .receive(on: DispatchQueue.main)
            .sink { [weak self] presentation in
                self?.updateForcedUpdateSheet(presentation)
            }
            .store(in: &cancellalbes)

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.refreshAppUpdateStatus()
            }
            .store(in: &cancellalbes)

        refreshAppUpdateStatus()
    }

    private func refreshAppUpdateStatus() {
        Task { [appUpdateController] in
            await appUpdateController.refresh()
        }
    }

    private func updateAppUpdateBanner(_ presentation: AppUpdatePresentation?) {
        guard let presentation else {
            removeAppUpdateBanner()
            return
        }

        let rootView = AppUpdateBannerView(
            presentation: presentation,
            onUpdate: { [weak self] url in
                self?.openAppStore(url)
            },
            onClose: { [weak self] in
                self?.appUpdateController.dismissBanner()
            }
        )

        if let appUpdateBannerController {
            appUpdateBannerController.rootView = rootView
            updateAppUpdateBannerHeight()
            return
        }

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .systemBackground

        addChild(hostingController)
        view.addSubview(hostingController.view)

        let heightConstraint = hostingController.view.heightAnchor.constraint(equalToConstant: 64)
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            heightConstraint
        ])

        hostingController.didMove(toParent: self)

        appUpdateBannerController = hostingController
        appUpdateBannerHeightConstraint = heightConstraint
        updateAppUpdateBannerHeight()
    }

    private func removeAppUpdateBanner() {
        guard let appUpdateBannerController else {
            additionalSafeAreaInsets.bottom = 0
            return
        }

        appUpdateBannerController.willMove(toParent: nil)
        appUpdateBannerController.view.removeFromSuperview()
        appUpdateBannerController.removeFromParent()

        self.appUpdateBannerController = nil
        appUpdateBannerHeightConstraint = nil
        additionalSafeAreaInsets.bottom = 0
    }

    private func updateAppUpdateBannerHeight() {
        guard let appUpdateBannerController, view.bounds.width > 0 else { return }

        let size = appUpdateBannerController.sizeThatFits(
            in: CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        )
        let height = max(64, ceil(size.height))

        appUpdateBannerHeightConstraint?.constant = height
        additionalSafeAreaInsets.bottom = height
    }

    private func updateForcedUpdateSheet(_ presentation: AppUpdatePresentation?) {
        guard let presentation else {
            if let appUpdateSheetController {
                appUpdateSheetController.dismiss(animated: true)
                self.appUpdateSheetController = nil
            }
            return
        }

        let rootView = AppUpdateSheetView(
            presentation: presentation,
            onUpdate: { [weak self] url in
                self?.openAppStore(url)
            },
            onClose: { [weak self] in
                self?.appUpdateController.dismissForcedSheet()
            }
        )

        if let appUpdateSheetController {
            appUpdateSheetController.rootView = rootView
            appUpdateSheetController.isModalInPresentation = !presentation.allowsDismissal
            return
        }

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.modalPresentationStyle = .formSheet
        hostingController.isModalInPresentation = !presentation.allowsDismissal

        dismiss(animated: false) { [weak self] in
            guard let self else { return }
            self.appUpdateSheetController = hostingController
            self.present(hostingController, animated: true) {
                hostingController.presentationController?.delegate = self
            }
        }
    }

    private func openAppStore(_ url: URL) {
        UIApplication.shared.open(url)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAppUpdateBannerHeight()
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard presentationController.presentedViewController === appUpdateSheetController else { return }

        appUpdateSheetController = nil
        appUpdateController.dismissForcedSheet()
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
        contentEntry.title = String.localized("Welcome to the festival village!")
        contentEntry.body = String.localized("The moers festival app helps you to easily find your way around the program. You can also put together your own program in the app and get lots of other important information.")
        contentEntry.subtitle = String.localized("Nice to see you!")
        
        let contentExit = UNMutableNotificationContent()
        contentExit.badge = nil
        contentExit.body = String.localized("Thanks for coming. We hope you had fun!")
        contentExit.title = String.localized("See you later!")
        
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

            let nextController = FallbackWebViewController(url: url)
            nextController.navigationItem.largeTitleDisplayMode = .never
            nextController.navigationCallback = fallbackController.navigationCallback

            if UIDevice.current.userInterfaceIdiom == .pad,
               let navigationController = fallbackController.navigationController {
                navigationController.pushViewController(nextController, animated: true)
            } else {
                self.showWebpage(url: url)
            }
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            let navigationController = UINavigationController(rootViewController: fallbackController)
            navigationController.modalPresentationStyle = .formSheet
            other.navigationController.present(navigationController, animated: true)
        } else {
            self.other.navigationController.pushViewController(fallbackController, animated: true)
        }
        
    }

    private func dismissMapPresentationIfNeeded(beforeSelecting viewController: UIViewController) {
        guard selectedViewController === map.rootViewController,
              viewController !== map.rootViewController,
              presentedViewController != nil else {
            return
        }

        dismiss(animated: false)
    }
    
}
