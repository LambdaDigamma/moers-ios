//
//  AppTabBarController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import AppScaffold
import UIKit
import BLTNBoard
import Events
import CoreLocation
import Combine
import FactoryKit
import RubbishFeature
import MapFeature
import FuelFeature

@MainActor
public class AppTabBarController: AppScaffold.TabBarController {

    @LazyInjected(\.rubbishService) var rubbishService
    @LazyInjected(\.petrolService) var petrolService
    @LazyInjected(\.locationManager) var locationManager
    
    var firstLaunch: FirstLaunch

    private var isSnapshotting: Bool {
        LaunchArgumentsHandler.isSnapshotting()
    }
    
    let dashboard: DashboardCoordinator
    let news: NewsCoordinator
    let map: MapCoordintor
    let events: EventCoordinator
    let other: OtherCoordinator
    
    private var userInterfaceStyleRegistration: UITraitChangeRegistration?
    private var isSuspendingMapForTabSelection = false
    private weak var pendingTabSelection: UIViewController?
    
    public var internalTabs: [any AppScaffold.TabRepresentable] {
        [dashboard, news, map, events, other]
    }
    
    init(firstLaunch: FirstLaunch) {
        
        self.firstLaunch = firstLaunch
        
        self.dashboard = DashboardCoordinator()
        self.news = NewsCoordinator()
        self.map = MapCoordintor()
        self.events = EventCoordinator()
        self.other = OtherCoordinator()
        
        super.init(nibName: nil, bundle: nil)

        if #available(iOS 18.0, *) {
            mode = .tabBar
        }

        if isSnapshotting {
            setupMocked()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCurrentLocation()
        
        self.viewControllers = internalTabs.map(\.rootViewController)
        delegate = self
        
        self.tabBar.accessibilityIdentifier = AccessibilityIdentifiers.tabBar
        
        self.applyTheming()
        self.registerForTraitChanges()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyTheming()
        loadRubbishData()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.firstLaunch = FirstLaunch(
            userDefaults: .appGroup,
            key: Constants.firstLaunch
        )

        if (firstLaunch.isFirstLaunch || !onboardingManager.userDidCompleteSetup) && !isSnapshotting {
            showBulletin()
        }

    }
    
    // MARK: - UI -

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if isSuspendingMapForTabSelection {
            pendingTabSelection = viewController
            return false
        }
        guard selectedViewController === map.rootViewController,
              viewController !== map.rootViewController else { return true }
        let mapController = map.mainViewController
        pendingTabSelection = viewController
        isSuspendingMapForTabSelection = true
        mapController.suspendPanelPresentation { [weak self] in
            guard let self else { return }
            let selection = pendingTabSelection
            pendingTabSelection = nil
            isSuspendingMapForTabSelection = false
            if let selection {
                selectedViewController = selection
                if selection === map.rootViewController { mapController.resumePanelPresentation() }
            }
        }
        return false
    }

    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController === map.rootViewController {
            map.mainViewController.resumePanelPresentation()
        }
    }
    
    private func registerForTraitChanges() {
        userInterfaceStyleRegistration = registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (controller: Self, previousTraitCollection: UITraitCollection) in
            
            if controller.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                controller.applyTheming()
            }
        }
    }
    
    private func applyTheming() {
        let theme = ApplicationTheme.current
        
        self.view.backgroundColor = theme.backgroundColor
        self.bulletinManager.backgroundColor = theme.backgroundColor
        self.bulletinManager.hidesHomeIndicator = false
        self.bulletinManager.edgeSpacing = .compact
        self.rubbishMigrationManager.backgroundColor = theme.backgroundColor
        self.rubbishMigrationManager.hidesHomeIndicator = false
        self.rubbishMigrationManager.edgeSpacing = .compact
        self.tabBar.tintColor = theme.accentColor
        self.tabBar.barTintColor = UIColor.systemBackground
        
        let barAppearance = UIBarAppearance()
        barAppearance.configureWithDefaultBackground()
        barAppearance.backgroundColor = UIColor.systemBackground
        
        self.tabBar.standardAppearance = UITabBarAppearance(barAppearance: barAppearance)
        self.tabBar.scrollEdgeAppearance = UITabBarAppearance(barAppearance: barAppearance)
        
//        let appearance = UINavigationBarAppearance()
//        
//        appearance.configureWithDefaultBackground()
//        appearance.backgroundColor = theme.navigationBarColor
//        
//        appearance.titleTextAttributes = [.foregroundColor: theme.accentColor]
//        appearance.largeTitleTextAttributes = [.foregroundColor: theme.accentColor]
//        
//        guard let controller = self.viewControllers?[2] as? UINavigationController else {
//            return
//        }
//        
//        controller.navigationBar.scrollEdgeAppearance = appearance
        
    }
    
    // MARK: - Onboarding -

    lazy var onboardingManager: OnboardingManager = {
        return OnboardingManager()
    }()

    lazy var bulletinManager: BLTNItemManager = {
        let onboarding = onboardingManager.makeOnboarding()
        return BLTNItemManager(rootItem: onboarding)
    }()

    lazy var rubbishMigrationManager: BLTNItemManager = {
        let page = makeRubbishMigrationPage()
        return BLTNItemManager(rootItem: page)
    }()

    // MARK: - Actions -

    public func updateDashboard() {
        dashboard.updateUI()
    }

    @objc func setupDidComplete() {

        AnalyticsManager.shared.logCompletedOnboarding()

        self.onboardingManager.userDidCompleteSetup = true
        self.updateDashboard()

    }

    private func showBulletin() {

        NotificationCenter.default.addObserver(self, selector: #selector(setupDidComplete), name: .SetupDidComplete, object: nil)

        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.statusBarAppearance = .hidden
        bulletinManager.showBulletin(above: self)

    }

    func registerRubbishMigrationStreet(_ street: RubbishCollectionStreet) {
        rubbishService.register(street)
        rubbishService.isEnabled = true
        if rubbishService.remindersEnabled {
            rubbishService.registerNotifications(
                at: rubbishService.reminderHour ?? 20,
                minute: rubbishService.reminderMinute ?? 0
            )
        }
    }

    private func makeRubbishMigrationPage() -> BLTNPageItem {

        let page = onboardingManager.makeRubbishStreetPage()
        page.descriptionText = String(localized: "Select your street again to see the current waste collection dates.")

        page.actionHandler = { [weak self] item in

            guard let item = item as? RubbishStreetPickerItem else { return }

            self?.registerRubbishMigrationStreet(item.selectedStreet)

            item.manager?.dismissBulletin(animated: true)

            self?.updateDashboard()

        }

        page.alternativeHandler = { [weak self] item in

            self?.rubbishService.isEnabled = false
            self?.rubbishService.remindersEnabled = false
            self?.rubbishService.disableReminder()

            item.manager?.dismissBulletin(animated: true)

            self?.updateDashboard()

        }

        return page

    }

    // MARK: - Data Handling -
    
    private func loadCurrentLocation() {
        
        locationManager.authorizationStatus.sink { [weak self] (authorizationStatus: CLAuthorizationStatus) in
            if authorizationStatus == .authorizedWhenInUse {
                self?.locationManager.requestCurrentLocation()
            }
        }
        .store(in: &cancellables)
        
    }
    
    private func loadRubbishData() {

        let rubbishService = Container.shared.rubbishService()

        if rubbishService.isEnabled &&
            !firstLaunch.isFirstLaunch &&
            onboardingManager.userDidCompleteSetup &&
            rubbishService.rubbishStreet != nil {

            Task {
                do {
                    let streets = try await rubbishService.loadRubbishCollectionStreets()

                    await MainActor.run {
                        let currentStreetName = rubbishService.rubbishStreet?.street ?? ""
                        let currentStreetAddition = rubbishService.rubbishStreet?.streetAddition

                        if let filteredStreet = streets.filter({
                            $0.street == currentStreetName &&
                            $0.streetAddition == currentStreetAddition
                        }).first {

                            rubbishService.register(filteredStreet)

                            if rubbishService.remindersEnabled {
                                rubbishService.registerNotifications(
                                    at: rubbishService.reminderHour ?? 20,
                                    minute: rubbishService.reminderMinute ?? 00
                                )
                            }

                        } else {

                            rubbishService.disableStreet()

                            self.rubbishMigrationManager.backgroundViewStyle = .dimmed
                            self.rubbishMigrationManager.statusBarAppearance = .hidden
                            self.rubbishMigrationManager.showBulletin(above: self)

                        }
                    }
                } catch {
                    print("Error loading rubbish collection streets: \(error.localizedDescription)")
                }
            }

        }

    }

    // MARK: - Helper -
    
    private func setupMocked() {
        
        UserManager.shared.register(User(type: .citizen, id: nil, name: nil, description: nil))
        petrolService.petrolType = .diesel
        
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
