//
//  MainSplitViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 06.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit
import AppScaffold
import MMUI
import MMAPI
import MMEvents
import OSLog
import BLTNBoard
import Resolver
import RubbishFeature
import Combine
import CoreLocation
import Gestalt

/// The main view controller which holds
public class MainSplitViewController: UISplitViewController, SidebarViewControllerDelegate, UISplitViewControllerDelegate {
    
    @LazyInjected var rubbishService: RubbishService
    
    private let logger: Logger = Logger(.default)
    
    var petrolManager: PetrolManagerProtocol
    let locationManager: LocationManagerProtocol
    let dashboard: DashboardCoordinator
    let news: NewsCoordinator
    let map: MapCoordintor
    let events: EventCoordinator
    let other: OtherCoordinator
    
    var firstLaunch: FirstLaunch
    
    internal let tabController: TabBarController
    internal let sidebarController: SidebarViewController
    internal let secondaryRootViewControllers: [UIViewController]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    public var onChangeTraitCollection: ((UITraitCollection) -> Void)?
    
    public var displayCompact: Bool {
        return self.traitCollection.horizontalSizeClass == .compact
    }
    
    public init(
        firstLaunch: FirstLaunch,
        locationManager: LocationManagerProtocol,
        petrolManager: PetrolManagerProtocol,
        cameraManager: CameraManagerProtocol,
        entryManager: EntryManagerProtocol,
        parkingLotManager: ParkingLotManagerProtocol,
        eventService: EventServiceProtocol
    ) {
        
        self.firstLaunch = firstLaunch
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        
        self.dashboard = DashboardCoordinator(
            petrolManager: petrolManager
        )
        
        self.news = NewsCoordinator()
        
        self.map = MapCoordintor(
            locationManager: locationManager,
            petrolManager: petrolManager,
            cameraManager: cameraManager,
            entryManager: entryManager,
            parkingLotManager: parkingLotManager
        )
        
        self.events = EventCoordinator(
            eventService: eventService
        )
        
        self.other = OtherCoordinator(
            entryManager: entryManager
        )
        
        let coordinators: [Coordinator] = [
            dashboard,
            news,
            map,
            events,
            other
        ]
        
        self.tabController = TabBarController(
            firstLaunch: firstLaunch,
            locationManager: locationManager,
            petrolManager: petrolManager,
            cameraManager: cameraManager,
            entryManager: entryManager,
            parkingLotManager: parkingLotManager,
            eventService: eventService
        )
        
        self.secondaryRootViewControllers = coordinators.map({ coordinator in
            coordinator.navigationController
        })
        
        self.sidebarController = SidebarViewController()
        
        super.init(style: .doubleColumn)
        
        self.configureSplitController()
        
        if isSnapshotting() {
            self.setupMocked()
        }
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTheming()
        self.loadRubbishData()
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.firstLaunch = FirstLaunch(
            userDefaults: .appGroup,
            key: Constants.firstLaunch
        )
        
        if (firstLaunch.isFirstLaunch || !onboardingManager.userDidCompleteSetup) && !isSnapshotting() {
            showBulletin()
        }
        
    }
    
    private func configureSplitController() {
        
        self.sidebarController.delegate = self
        
        self.delegate = self
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        self.showsSecondaryOnlyButton = true
        self.presentsWithGesture = true
        
        if #available(iOS 14.5, *) {
            self.displayModeButtonVisibility = .always
        }
        
        self.setViewController(tabController, for: .compact)
        self.setViewController(sidebarController, for: .primary)
        self.setViewController(secondaryRootViewControllers[0], for: .secondary)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func isSnapshotting() -> Bool {
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    }
    
    private func setupMocked() {
        
        UserManager.shared.register(User(type: .citizen, id: nil, name: nil, description: nil))
        petrolManager.petrolType = .diesel
        
    }
    
    // MARK: - UISplitViewControllerDelegate -
    
    public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        
        self.logger.info("MainSplitViewController changes to \(displayMode.rawValue, privacy: .public)")
        
    }
    
    // MARK: - Sidebar Handling -
    
    public func sidebar(_ sidebarViewController: SidebarViewController, didSelectTabItem item: SidebarItem) {
        
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        
        if let index = SidebarItem.tabs.firstIndex(of: item) {
            let indexPath = IndexPath(item: index, section: 0)
            self.setViewController(secondaryRootViewControllers[indexPath.row], for: .secondary)
        }
        
    }
    
    public func selectSidebarItem(_ item: SidebarItem) {
        
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        
        if let index = SidebarItem.tabs.firstIndex(of: item) {
            self.sidebarController.selectIndex(index)
            self.setViewController(secondaryRootViewControllers[index], for: .secondary)
        }
        
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if let previousTraitCollection = previousTraitCollection {
            
            if previousTraitCollection.horizontalSizeClass != traitCollection.horizontalSizeClass &&
                traitCollection.userInterfaceIdiom == .pad {
                onChangeTraitCollection?(traitCollection)
            }
            
        }
        
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
        if self.isCollapsed {
            tabController.dashboard.updateUI()
        } else {
            dashboard.updateUI()
        }
    }
    
    @objc func setupDidComplete() {
        
        AnalyticsManager.shared.logCompletedOnboarding()
        
        self.onboardingManager.userDidCompleteSetup = true
        self.loadCurrentLocation()
        self.updateDashboard()
        
    }
    
    private func showBulletin() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupDidComplete), name: .SetupDidComplete, object: nil)
        
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.statusBarAppearance = .hidden
        bulletinManager.showBulletin(above: self)
        
    }
    
    private func makeRubbishMigrationPage() -> BLTNPageItem {
        
        let page = onboardingManager.makeRubbishStreetPage()
        page.descriptionText = "Wähle Deine Straße erneut aus, um die aktuellen Abfuhrtermine der Müllabfuhr angezeigt zu bekommen."
        
        page.actionHandler = { [weak self] item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            if var rubbishService = self?.rubbishService {
                
                rubbishService.register(item.selectedStreet)
                rubbishService.isEnabled = true
                
                if rubbishService.remindersEnabled {
                    rubbishService.registerNotifications(
                        at: rubbishService.reminderHour ?? 20,
                        minute: rubbishService.reminderHour ?? 00
                    )
                }
                
            }
            
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
    
    // MARK: - Data Handling
    
    private func loadCurrentLocation() {
        
        locationManager.authorizationStatus.sink { (authorizationStatus: CLAuthorizationStatus) in
            if authorizationStatus == .authorizedWhenInUse {
                self.locationManager.requestCurrentLocation()
            }
        }
        .store(in: &cancellables)
        
    }
    
    private func loadRubbishData() {
        
        let rubbishService: RubbishService? = Resolver.optional()
        
        guard let rubbishService = rubbishService else {
            return
        }
        
        if rubbishService.isEnabled &&
            !firstLaunch.isFirstLaunch &&
            onboardingManager.userDidCompleteSetup &&
            rubbishService.rubbishStreet != nil {
            
            rubbishService.loadRubbishCollectionStreets()
                .receive(on: DispatchQueue.main)
                .sink { (_: Subscribers.Completion<Error>) in
                    
                } receiveValue: { (streets: [RubbishFeature.RubbishCollectionStreet]) in
                    
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
                .store(in: &cancellables)
            
        }
        
    }
    
}

extension MainSplitViewController: Themeable {
    
    public typealias Theme = ApplicationTheme
    
    public func apply(theme: Theme) {
        
        self.view.backgroundColor = theme.backgroundColor
        self.bulletinManager.backgroundColor = theme.backgroundColor
        self.bulletinManager.hidesHomeIndicator = false
        self.bulletinManager.edgeSpacing = .compact
        self.rubbishMigrationManager.backgroundColor = theme.backgroundColor
        self.rubbishMigrationManager.hidesHomeIndicator = false
        self.rubbishMigrationManager.edgeSpacing = .compact
        
        let barAppearance = UIBarAppearance()
        barAppearance.configureWithDefaultBackground()
        barAppearance.backgroundColor = UIColor.systemBackground
        
    }
    
}
