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

    lazy var dashboardViewController = { DashboardViewController() }()
    lazy var newsViewController = { NewsViewController() }()
    lazy var eventViewController = { MMEventsViewController() }()
    lazy var otherViewController = { OtherViewController() }()
    lazy var mainViewController: MainViewController = {
        
        let mapViewController = MapViewController()
        let contentViewController = UIStoryboard(name: "ContentDrawer", bundle: nil).instantiateViewController(withIdentifier: "DrawerContentViewController")
        
        let mainViewController = MainViewController(contentViewController: mapViewController, drawerViewController: contentViewController)
        
        return mainViewController
        
    }()
    
    lazy var bulletinManager: BLTNItemManager = {
        let onboarding = OnboardingManager.shared.makeOnboarding()
        return BLTNItemManager(rootItem: onboarding)
    }()
    
    lazy var rubbishMigrationManager: BLTNItemManager = {
        let page = makeRubbishMigrationPage()
        return BLTNItemManager(rootItem: page)
    }()
    
    private var firstLaunch: FirstLaunch
    
    init() {
//        #if DEBUG
//        self.firstLaunch = FirstLaunch.alwaysFirst()
//        #else
        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: "FirstLaunch.WasLaunchedBefore")
//        #endif
        
        super.init(nibName: nil, bundle: nil)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: "FirstLaunch.WasLaunchedBefore")
        
        self.delegate = self
        
        self.loadData()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dashboard = navigation(with: dashboardViewController,
                                   and: ESTabBarItem(ItemBounceContentView(), title: String.localized("DashboardTabItem"), image: #imageLiteral(resourceName: "dashboard"), selectedImage: #imageLiteral(resourceName: "dashboard")))
        
        let news = navigation(with: newsViewController,
                              and: ESTabBarItem(ItemBounceContentView(), title: String.localized("NewsTitle"), image: #imageLiteral(resourceName: "news"), selectedImage: #imageLiteral(resourceName: "news")))
        
        let main = navigation(with: mainViewController,
                             and: ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "map_marker"), selectedImage: #imageLiteral(resourceName: "map_marker")))
        
        let event = navigation(with: eventViewController,
                               and: ESTabBarItem(ItemBounceContentView(), title: String.localized("Events"), image: #imageLiteral(resourceName: "calendar"), selectedImage: #imageLiteral(resourceName: "calendar")))
        
        let other = navigation(with: otherViewController,
                               and: ESTabBarItem(ItemBounceContentView(), title: String.localized("OtherTabItem"), image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list")))
        
        // Testing
        
        /*
        let community = navigation(with: communityViewController,
                                   and: ESTabBarItem(ItemBounceContentView(), title: "Community", image: #imageLiteral(resourceName: "people"), selectedImage: #imageLiteral(resourceName: "people")))
        
        let leaderboard = navigation(with: leaderboardViewController,
                                     and: ESTabBarItem(ItemBounceContentView(), title: String.localized("LeaderboardTitle"), image: #imageLiteral(resourceName: "trophy"), selectedImage: #imageLiteral(resourceName: "trophy")))
        
        let organisationDetail = navigation(with: organisationDetailViewController,
                                            and: ESTabBarItem(ItemBounceContentView(), title: "Test", image: #imageLiteral(resourceName: "trophy"), selectedImage: #imageLiteral(resourceName: "trophy")))
        */
        
        self.viewControllers = [dashboard, news, main, event, other]
        
        self.setupTheming()
        
        self.loadRubbishData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (firstLaunch.isFirstLaunch || !OnboardingManager.shared.userDidCompleteSetup) && !isSnapshotting() {
            
            showBulletin()
            
        }
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        
        if let item = item as? ESTabBarItem {
            
            if item.contentView is MapItemContentView {
                
                let tabBarItem = ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "search"), selectedImage: #imageLiteral(resourceName: "search"))
                
                tabBarItem.contentView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(search)))
                
                self.shouldHijackHandler = {
                    tabbarController, viewController, index in
                    
                    return index == 2
                    
                }
                
                self.didHijackHandler = {
                    tabbarController, viewController, index in
                    
                    self.search()
                    
                }
                
                viewControllers?[2].tabBarItem = tabBarItem
                
            } else {
                
                viewControllers?[2].tabBarItem = ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "map_marker"), selectedImage: #imageLiteral(resourceName: "map_marker"))
                
                self.shouldHijackHandler = nil
                
            }
            
        }
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            UIApplication.shared.statusBarStyle = theme.statusBarStyle
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.tabBar.tintColor = theme.accentColor
            themeable.tabBar.barTintColor = theme.navigationBarColor
            themeable.bulletinManager.backgroundColor = theme.backgroundColor
            themeable.bulletinManager.hidesHomeIndicator = false
            themeable.bulletinManager.edgeSpacing = .compact
            themeable.rubbishMigrationManager.backgroundColor = theme.backgroundColor
            themeable.rubbishMigrationManager.hidesHomeIndicator = false
            themeable.rubbishMigrationManager.edgeSpacing = .compact
            
            if let viewControllers = themeable.viewControllers {
                
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
    
    private func showBulletin() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupDidComplete), name: .SetupDidComplete, object: nil)
        
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.statusBarAppearance = .hidden
        bulletinManager.showBulletin(above: self)
        
    }
    
    private func loadRubbishData() {
        
//        RubbishManager.shared.street = "Adler"
        
        if RubbishManager.shared.isEnabled && !firstLaunch.isFirstLaunch && OnboardingManager.shared.userDidCompleteSetup && (RubbishManager.shared.rubbishStreet?.street ?? "") != "" {
            
            RubbishManager.shared.loadRubbishCollectionStreets { (streets) in
                
                let currentStreetName = RubbishManager.shared.rubbishStreet?.street ?? ""
                
                if let filteredStreet = streets.filter({ $0.street == currentStreetName }).first {
                    
                    RubbishManager.shared.register(filteredStreet)
                    
                    if RubbishManager.shared.remindersEnabled {
                        RubbishManager.shared.registerNotifications(at: RubbishManager.shared.reminderHour ?? 20, minute: RubbishManager.shared.reminderHour ?? 00)
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
    
    private func setupMocked() {
        
        let rubbishCollectionStreet = RubbishCollectionStreet(street: "Adlerstraße",
                                                              residualWaste: 3,
                                                              organicWaste: 2,
                                                              paperWaste: 8,
                                                              yellowBag: 3,
                                                              greenWaste: 2,
                                                              sweeperDay: "")
        
        UserManager.shared.register(User(type: .citizen, id: nil, name: nil, description: nil))
        PetrolManager.shared.petrolType = .diesel
        RubbishManager.shared.isEnabled = true
        RubbishManager.shared.register(rubbishCollectionStreet)
        
    }
    
    private func navigation(with controller: UIViewController, and tabItem: ESTabBarItem) -> UINavigationController {
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [controller]
        
        navigationController.tabBarItem = tabItem
        
        return navigationController
        
    }
    
    @objc func setupDidComplete() {
        
        OnboardingManager.shared.userDidCompleteSetup = true
        AnalyticsManager.shared.logCompletedOnboarding()
        
        self.loadData()
        
        dashboardViewController.reloadUI()
        dashboardViewController.triggerUpdate()
        
    }
    
    @objc func search() {
        
        mainViewController.setDrawerPosition(position: .open, animated: true)
        mainViewController.contentViewController.searchBar.becomeFirstResponder()
        
    }
    
    private func makeRubbishMigrationPage() -> BLTNPageItem {
        
        let page = OnboardingManager.shared.makeRubbishStreetPage()
        page.descriptionText = "Wähle Deine Straße erneut aus, um die aktuellen Abfuhrtermine der Müllabfuhr angezeigt zu bekommen."
        
        page.actionHandler = { item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            let selectedStreet = item.streets[item.picker.currentSelectedRow]
            
            RubbishManager.shared.register(selectedStreet)
            RubbishManager.shared.isEnabled = true
            
            if RubbishManager.shared.remindersEnabled {
                RubbishManager.shared.registerNotifications(at: RubbishManager.shared.reminderHour ?? 20, minute: RubbishManager.shared.reminderHour ?? 00)
            }
            
            item.manager?.dismissBulletin(animated: true)
            
        }
        
        page.alternativeHandler = { item in
            
            RubbishManager.shared.isEnabled = false
            RubbishManager.shared.remindersEnabled = false
            RubbishManager.shared.disableReminder()
            
            item.manager?.dismissBulletin(animated: true)
            
            self.dashboardViewController.reloadUI()
            self.dashboardViewController.triggerUpdate()
            
        }
        
        return page
        
    }
    
    // MARK: - Data Handling
    
    private func loadData() {
        
        if LocationManager.shared.authorizationStatus == .authorizedWhenInUse
            || LocationManager.shared.authorizationStatus == .authorizedAlways {
            
            LocationManager.shared.getCurrentLocation(completion: { (_, _) in })
            
        }
        
    }
    
    private func isSnapshotting() -> Bool {
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    }
    
}
