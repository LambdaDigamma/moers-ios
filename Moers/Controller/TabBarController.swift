//
//  TabBarController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard
import Gestalt
import MMAPI
import MMUI
import MMEvents
import CoreLocation
import Combine
import Resolver
import RubbishFeature

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    @LazyInjected var rubbishService: RubbishService
    
    var firstLaunch: FirstLaunch
    
    let dashboard: DashboardCoordinator
    let news: NewsCoordinator
    let map: MapCoordintor
    let events: EventCoordinator
    let other: OtherCoordinator
    
    let locationManager: LocationManagerProtocol
    let cameraManager: CameraManagerProtocol
    let entryManager: EntryManagerProtocol
    let parkingLotManager: ParkingLotManagerProtocol
    var petrolManager: PetrolManagerProtocol
    let eventService: EventServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    init(
        locationManager: LocationManagerProtocol,
        petrolManager: PetrolManagerProtocol,
        cameraManager: CameraManagerProtocol,
        entryManager: EntryManagerProtocol,
        parkingLotManager: ParkingLotManagerProtocol,
        eventService: EventServiceProtocol
    ) {
        
        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: Constants.firstLaunch)
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        self.parkingLotManager = parkingLotManager
        self.eventService = eventService
        
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
        
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = self
        
        if isSnapshotting() {
            self.setupMocked()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCurrentLocation()
        
        self.viewControllers = [
            dashboard.navigationController,
            news.navigationController,
            map.navigationController,
            events.navigationController,
            other.navigationController
        ]
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTheming()
        self.loadRubbishData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: Constants.firstLaunch)
        
        if (firstLaunch.isFirstLaunch || !onboardingManager.userDidCompleteSetup) && !isSnapshotting() {
            showBulletin()
        }
        
    }
    
    // MARK: - UI
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    // MARK: - Actions
    
    public func updateDashboard() {
        dashboard.updateUI()
    }
    
    @objc func setupDidComplete() {
        
        AnalyticsManager.shared.logCompletedOnboarding()
        
        self.onboardingManager.userDidCompleteSetup = true
        self.loadCurrentLocation()
        self.updateDashboard()
        
    }
    
    @objc func search() {
        map.showSearch()
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
                .sink { (completion: Subscribers.Completion<Error>) in
                    
                } receiveValue: { (streets: [RubbishFeature.RubbishCollectionStreet]) in
                    
                    let currentStreetName = rubbishService.rubbishStreet?.street ?? ""
                    let currentStreetAddition = rubbishService.rubbishStreet?.streetAddition ?? ""
                    
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
    
    // MARK: - Helper
    
    private func isSnapshotting() -> Bool {
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    }
    
    private func setupMocked() {
        
        let rubbishCollectionStreet = RubbishFeature.RubbishCollectionStreet(
            id: 2,
            street: "Adlerstraße",
            streetAddition: nil,
            residualWaste: 3,
            organicWaste: 2,
            paperWaste: 8,
            yellowBag: 3,
            greenWaste: 2,
            sweeperDay: "",
            year: 2020
        )
        
        UserManager.shared.register(User(type: .citizen, id: nil, name: nil, description: nil))
        petrolManager.petrolType = .diesel
        rubbishService.isEnabled = true
        rubbishService.register(rubbishCollectionStreet)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}

extension TabBarController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
//        UIApplication.shared.statusBarStyle = theme.statusBarStyle
        self.view.backgroundColor = theme.backgroundColor
        self.tabBar.tintColor = theme.accentColor
        self.tabBar.barTintColor = UIColor.systemBackground // UIColor.black //theme.navigationBarColor
        self.bulletinManager.backgroundColor = theme.backgroundColor
        self.bulletinManager.hidesHomeIndicator = false
        self.bulletinManager.edgeSpacing = .compact
        self.rubbishMigrationManager.backgroundColor = theme.backgroundColor
        self.rubbishMigrationManager.hidesHomeIndicator = false
        self.rubbishMigrationManager.edgeSpacing = .compact
        
        self.tabBar.barStyle = .black
        
        let barAppearance = UIBarAppearance()
        barAppearance.configureWithDefaultBackground()
        barAppearance.backgroundColor = UIColor.systemBackground // UIColor.black
        
        self.tabBar.standardAppearance = UITabBarAppearance(barAppearance: barAppearance)
        
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = UITabBarAppearance(barAppearance: barAppearance)
        }
        
        if let viewControllers = self.viewControllers {
            
            for navigationController in viewControllers {
                
                guard let nav = navigationController as? UINavigationController else { return }
                
                nav.navigationBar.barTintColor = theme.navigationBarColor
                nav.navigationBar.tintColor = theme.accentColor
                nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
                nav.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
                nav.navigationBar.isTranslucent = true
                nav.navigationBar.prefersLargeTitles = true
                
                if theme.statusBarStyle == .lightContent {
                    self.tabBar.barStyle = .black
                    nav.navigationBar.barStyle = .black
                } else {
                    self.tabBar.barStyle = .default
                    nav.navigationBar.barStyle = .default
                }
                
            }
            
        }
        
        if #available(iOS 13.0, *) {
            
            let appearance = UINavigationBarAppearance()
            
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = theme.navigationBarColor
            
            appearance.titleTextAttributes = [.foregroundColor : theme.accentColor]
            appearance.largeTitleTextAttributes = [.foregroundColor : theme.accentColor]
            
            guard let controller = self.viewControllers?[2] as? UINavigationController else { return }
            
            controller.navigationBar.scrollEdgeAppearance = appearance
            
        }
        
    }
    
}
