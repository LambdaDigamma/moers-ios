//
//  AppSplitViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 06.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Core
import Foundation
import OSLog
import Resolver
import CoreLocation
import Gestalt
import Combine
import UIKit
import AppScaffold
import MMUI
import MMEvents
import BLTNBoard
import RubbishFeature
import FuelFeature
import MapFeature

public class AppSplitViewController: SplitViewController {
    
    @LazyInjected var rubbishService: RubbishService
    @LazyInjected var petrolService: PetrolService
    
    let locationManager: LocationManagerProtocol
    let dashboard: DashboardCoordinator
    let news: NewsCoordinator
    let map: MapCoordintor
    let events: EventCoordinator
    let other: OtherCoordinator
    
    internal let tabController: AppTabBarController
    
    public init(
        firstLaunch: FirstLaunch,
        locationManager: LocationManagerProtocol,
        cameraManager: CameraManagerProtocol
    ) {
        
        self.locationManager = locationManager
        
        self.dashboard = DashboardCoordinator()
        self.news = NewsCoordinator()
        
        self.map = MapCoordintor(
            locationManager: locationManager
        )
        
        self.events = EventCoordinator()
        self.other = OtherCoordinator()
        
        let coordinators: [Coordinator] = [
            dashboard,
            news,
            map,
            events,
            other
        ]
        
        self.tabController = AppTabBarController(
            firstLaunch: firstLaunch,
            locationManager: locationManager,
            cameraManager: cameraManager
        )
        
        let secondaryRootViewControllers = coordinators.map({ coordinator in
            coordinator.navigationController
        })
        
        super.init(
            firstLaunch: firstLaunch,
            style: .doubleColumn,
            sidebarController: AppSidebarViewController(),
            compactController: tabController,
            secondaryRootViewControllers: secondaryRootViewControllers
        )
        
        self.sidebarItems = SidebarItem.tabs
        self.configureSplitController()
        
        if isSnapshotting {
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
        
        if (firstLaunch.isFirstLaunch || !onboardingManager.userDidCompleteSetup) && !isSnapshotting {
            showBulletin()
        }
        
    }
    
    public override func configureSplitController() {
        super.configureSplitController()
        
        self.setViewController(tabController, for: .compact)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupMocked() {
        
        UserManager.shared.register(User(type: .citizen, id: nil, name: nil, description: nil))
        petrolService.petrolType = .diesel
        
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

extension AppSplitViewController: Themeable {
    
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
