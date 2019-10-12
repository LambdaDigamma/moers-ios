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
import ESTabBarController
import MMAPI
import MMUI

class TabBarController: ESTabBarController, UITabBarControllerDelegate {

    let firstLaunch: FirstLaunch
    
    let dashboardViewController: DashboardViewController
    let newsViewController: NewsViewController
    let mainViewController: MainViewController
    let eventViewController: MMEventsViewController
    let otherViewController: OtherViewController
    
    let locationManager: LocationManagerProtocol
    let geocodingManager: GeocodingManagerProtocol
    let cameraManager: CameraManagerProtocol
    let entryManager: EntryManagerProtocol
    let parkingLotManager: ParkingLotManagerProtocol
    var petrolManager: PetrolManagerProtocol
    var rubbishManager: RubbishManagerProtocol
    
    lazy var onboardingManager: OnboardingManager = {
       
        return OnboardingManager(locationManager: locationManager,
                                 geocodingManager: geocodingManager,
                                 rubbishManager: rubbishManager,
                                 petrolManager: petrolManager)
        
    }()
    
    lazy var bulletinManager: BLTNItemManager = {
        let onboarding = onboardingManager.makeOnboarding()
        return BLTNItemManager(rootItem: onboarding)
    }()
    
    lazy var rubbishMigrationManager: BLTNItemManager = {
        let page = makeRubbishMigrationPage()
        return BLTNItemManager(rootItem: page)
    }()
    
    init(locationManager: LocationManagerProtocol,
         petrolManager: PetrolManagerProtocol,
         rubbishManager: RubbishManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         cameraManager: CameraManagerProtocol,
         entryManager: EntryManagerProtocol,
         parkingLotManager: ParkingLotManagerProtocol) {
        
        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: Constants.firstLaunch)
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.rubbishManager = rubbishManager
        self.geocodingManager = geocodingManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        self.parkingLotManager = parkingLotManager
        
        let mapViewController = MapViewController(locationManager: locationManager)
        let contentViewController = UIStoryboard(name: "ContentDrawer", bundle: nil).instantiateViewController(withIdentifier: "DrawerContentViewController")
        
        self.dashboardViewController = DashboardViewController(locationManager: locationManager,
                                                               geocodingManager: geocodingManager,
                                                               petrolManager: petrolManager)
        
        self.newsViewController = NewsViewController()
        self.mainViewController = MainViewController(contentViewController: mapViewController,
                                                     drawerViewController: contentViewController,
                                                     locationManager: locationManager,
                                                     petrolManager: petrolManager,
                                                     cameraManager: cameraManager,
                                                     entryManager: entryManager,
                                                     parkingLotManager: parkingLotManager)
        self.eventViewController = MMEventsViewController()
        self.otherViewController = OtherViewController(locationManager: locationManager,
                                                       geocodingManager: geocodingManager,
                                                       rubbishManager: rubbishManager,
                                                       petrolManager: petrolManager)
        
        if let contentViewController = contentViewController as? ContentViewController {
            contentViewController.locationManager = locationManager
        }
        
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
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabControllerFactory = TabControllerFactory()
        
        let dashboardTab = tabControllerFactory.buildTabItem(
            using: ItemBounceContentView(),
            title: String.localized("DashboardTabItem"),
            image: #imageLiteral(resourceName: "dashboard"),
            accessibilityLabel: String.localized("DashboardTabItem"),
            accessibilityIdentifier: "TabDashboard")
        
        let newsTab = tabControllerFactory.buildTabItem(
            using: ItemBounceContentView(),
            title: String.localized("NewsTitle"),
            image: #imageLiteral(resourceName: "news"),
            accessibilityLabel: String.localized("NewsTitle"),
            accessibilityIdentifier: "TabNews")
        
        let mapTab = tabControllerFactory.buildTabItem(
            using: MapItemContentView(),
            image: #imageLiteral(resourceName: "map_marker"),
            accessibilityLabel: String.localized("MapTabItem"),
            accessibilityIdentifier: "TabMap")
        
        let eventsTab = tabControllerFactory.buildTabItem(
            using: ItemBounceContentView(),
            title: String.localized("Events"),
            image: #imageLiteral(resourceName: "calendar"),
            accessibilityLabel: String.localized("Events"),
            accessibilityIdentifier: "TabEvents")
        
        let otherTab = tabControllerFactory.buildTabItem(
            using: ItemBounceContentView(),
            title: String.localized("OtherTabItem"),
            image: #imageLiteral(resourceName: "list"),
            accessibilityLabel: String.localized("OtherTabItem"),
            accessibilityIdentifier: "TabOther")
        
        let dashboard = tabControllerFactory.buildNavigationController(
            using: dashboardViewController,
            tabItem: dashboardTab)
        
        let news = tabControllerFactory.buildNavigationController(
            using: newsViewController,
            tabItem: newsTab)
        
        let map = tabControllerFactory.buildNavigationController(
            using: mainViewController,
            tabItem: mapTab)
        
        let events = tabControllerFactory.buildNavigationController(
            using: eventViewController,
            tabItem: eventsTab)
        
        let other = tabControllerFactory.buildNavigationController(
            using: otherViewController,
            tabItem: otherTab)
        
        self.viewControllers = [dashboard, news, map, events, other]
        
        self.setupTheming()
        self.loadRubbishData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (firstLaunch.isFirstLaunch || !onboardingManager.userDidCompleteSetup) && !isSnapshotting() {
            showBulletin()
        }
        
    }
    
    // MARK: - UITabBarDelegate
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        
        if let item = item as? ESTabBarItem {
            
            if item.contentView is MapItemContentView {
                
                item.image = #imageLiteral(resourceName: "search")
                item.selectedImage = #imageLiteral(resourceName: "search")
                item.accessibilityIdentifier = "TabMapSearch"
                item.accessibilityLabel = String.localized("SearchMap")
                
                item.contentView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(search)))
                
                self.shouldHijackHandler = { _, _, index in
                    
                    return index == 2
                    
                }
                
                self.didHijackHandler = { _, _, _ in
                    
                    self.search()
                    
                }
                
            } else {
                
                self.shouldHijackHandler = nil
                
                guard let item = viewControllers?[2].tabBarItem else { return }
                
                item.image = #imageLiteral(resourceName: "map_marker")
                item.selectedImage = #imageLiteral(resourceName: "map_marker")
                item.accessibilityLabel = String.localized("MapTabItem")
                item.accessibilityIdentifier = "TabMap"
                
            }
            
        }
        
    }
    
    // MARK: - UI
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    // MARK: - Actions
    
    public func updateDashboard() {
        dashboardViewController.reloadUI()
        dashboardViewController.triggerUpdate()
    }
    
    @objc func setupDidComplete() {
        
        AnalyticsManager.shared.logCompletedOnboarding()
        
        self.onboardingManager.userDidCompleteSetup = true
        self.loadCurrentLocation()
        self.updateDashboard()
        
    }
    
    @objc func search() {
        
        mainViewController.setDrawerPosition(position: .open, animated: true)
        mainViewController.contentViewController.searchBar.becomeFirstResponder()
        
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
        
        page.actionHandler = { item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            RubbishManager.shared.register(item.selectedStreet)
            RubbishManager.shared.isEnabled = true
            
            if RubbishManager.shared.remindersEnabled {
                RubbishManager.shared.registerNotifications(at: RubbishManager.shared.reminderHour ?? 20,
                                                            minute: RubbishManager.shared.reminderHour ?? 00)
            }
            
            item.manager?.dismissBulletin(animated: true)
            
        }
        
        page.alternativeHandler = { item in
            
            RubbishManager.shared.isEnabled = false
            RubbishManager.shared.remindersEnabled = false
            RubbishManager.shared.disableReminder()
            
            item.manager?.dismissBulletin(animated: true)
            
            self.updateDashboard()
            
        }
        
        return page
        
    }
    
    // MARK: - Data Handling
    
    private func loadCurrentLocation() {
        
        locationManager.authorizationStatus.observeNext { authorizationStatus in
            if authorizationStatus == .authorizedWhenInUse {
                self.locationManager.requestCurrentLocation()
            }
        }.dispose(in: bag)
        
    }
    
    private func loadRubbishData() {
        
        //        RubbishManager.shared.street = "Adler"
        
        if RubbishManager.shared.isEnabled && !firstLaunch.isFirstLaunch &&
            onboardingManager.userDidCompleteSetup &&
            (RubbishManager.shared.rubbishStreet?.street ?? "") != "" {
            
            RubbishManager.shared.loadRubbishCollectionStreets { (streets) in
                
                let currentStreetName = self.rubbishManager.rubbishStreet?.street ?? ""
                
                if let filteredStreet = streets.filter({ $0.street == currentStreetName }).first {
                    
                    RubbishManager.shared.register(filteredStreet)
                    
                    if RubbishManager.shared.remindersEnabled {
                        RubbishManager.shared.registerNotifications(at: RubbishManager.shared.reminderHour ?? 20,
                                                                    minute: RubbishManager.shared.reminderHour ?? 00)
                    }
                    
                } else {
                    
                    RubbishManager.shared.disableStreet()
                    
                    self.rubbishMigrationManager.backgroundViewStyle = .dimmed
                    self.rubbishMigrationManager.statusBarAppearance = .hidden
                    self.rubbishMigrationManager.showBulletin(above: self)
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - Helper
    
    private func isSnapshotting() -> Bool {
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    }
    
    private func setupMocked() {
        
        let rubbishCollectionStreet = RubbishCollectionStreet(street: "Adlerstraße",
                                                              residualWaste: 3,
                                                              organicWaste: 2,
                                                              paperWaste: 8,
                                                              yellowBag: 3,
                                                              greenWaste: 2,
                                                              sweeperDay: "")
        
        UserManager.shared.register(User(type: .citizen, id: nil, name: nil, description: nil))
        petrolManager.petrolType = .diesel
        rubbishManager.isEnabled = true
        rubbishManager.register(rubbishCollectionStreet)
        
    }
    
}

extension TabBarController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        UIApplication.shared.statusBarStyle = theme.statusBarStyle
        self.view.backgroundColor = theme.backgroundColor
        self.tabBar.tintColor = theme.accentColor
        self.tabBar.barTintColor = theme.navigationBarColor
        self.bulletinManager.backgroundColor = theme.backgroundColor
        self.bulletinManager.hidesHomeIndicator = false
        self.bulletinManager.edgeSpacing = .compact
        self.rubbishMigrationManager.backgroundColor = theme.backgroundColor
        self.rubbishMigrationManager.hidesHomeIndicator = false
        self.rubbishMigrationManager.edgeSpacing = .compact
        
        if let viewControllers = self.viewControllers {
            
            for navigationController in viewControllers {
                
                guard let nav = navigationController as? UINavigationController else { return }
                
                nav.navigationBar.barTintColor = theme.navigationBarColor
                nav.navigationBar.tintColor = theme.accentColor
                nav.navigationBar.prefersLargeTitles = true
                nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.accentColor]
                nav.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.accentColor]
                nav.navigationBar.isTranslucent = true
                
                if theme.statusBarStyle == .lightContent {
                    self.tabBar.barStyle = .black
                    nav.navigationBar.barStyle = .black
                } else {
                    self.tabBar.barStyle = .default
                    nav.navigationBar.barStyle = .default
                }
                
            }
            
        }
        
    }
    
}
