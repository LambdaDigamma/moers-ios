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

class TabBarController: ESTabBarController, UITabBarControllerDelegate {

    lazy var dashboardViewController: UIViewController = {
        
        let dashboardViewController = DashboardViewController()
        
        dashboardViewController.navigationItem.title = String.localized("DashboardTabItem")
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [dashboardViewController]
        
        let dashboardTabItem = ESTabBarItem(ItemBounceContentView(), title: String.localized("DashboardTabItem"), image: #imageLiteral(resourceName: "dashboard"), selectedImage: #imageLiteral(resourceName: "dashboard"))
        
        navigationController.tabBarItem = dashboardTabItem
        
        return navigationController
        
    }()
    
    lazy var newsViewController: UIViewController = {
        
        let newsViewController = NewsViewController()
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [newsViewController]
        
        let newsTabItem = ESTabBarItem(ItemBounceContentView(), title: String.localized("NewsTitle"), image: #imageLiteral(resourceName: "news"), selectedImage: #imageLiteral(resourceName: "news"))
        
        navigationController.tabBarItem = newsTabItem
        
        return navigationController
        
    }()
    
    lazy var mapViewController: UIViewController = {
        
        let mapViewController = MapViewController()
        let contentViewController = UIStoryboard(name: "ContentDrawer", bundle: nil).instantiateViewController(withIdentifier: "DrawerContentViewController")
        
        let mainViewController = MainViewController(contentViewController: mapViewController, drawerViewController: contentViewController)
        
        mainViewController.navigationItem.title = String.localized("MapTabItem")
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [mainViewController]
        
        let mapTabItem = ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "map_marker"), selectedImage: #imageLiteral(resourceName: "map_marker"))
        
        navigationController.tabBarItem = mapTabItem
        
        return navigationController
        
    }()
    
    lazy var eventViewController: UIViewController = {
       
        let eventViewController = EventViewController()
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [eventViewController]
        
        let eventTabItem = ESTabBarItem(ItemBounceContentView(), title: String.localized("Events"), image: #imageLiteral(resourceName: "calendar"), selectedImage: #imageLiteral(resourceName: "calendar"))
        
        navigationController.tabBarItem = eventTabItem
        
        return navigationController
        
    }()
    
    lazy var communityViewController: UIViewController = {
        
        let leaderboardViewController = CommunityViewController()
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [leaderboardViewController]
        
        let communityTabItem = ESTabBarItem(ItemBounceContentView(), title: "Community", image: #imageLiteral(resourceName: "people"), selectedImage: #imageLiteral(resourceName: "people"))
        
        navigationController.tabBarItem = communityTabItem
        
        return navigationController
        
    }()
    
    lazy var leaderboardViewController: UIViewController = {
        
        let leaderboardViewController = LeaderboardViewController()
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [leaderboardViewController]
        
        let leaderboardTabItem = ESTabBarItem(ItemBounceContentView(), title: String.localized("LeaderboardTitle"), image: #imageLiteral(resourceName: "trophy"), selectedImage: #imageLiteral(resourceName: "trophy"))
        
        navigationController.tabBarItem = leaderboardTabItem
        
        return navigationController
        
    }()
    
    lazy var otherViewController: UIViewController = {
        
        let otherViewController = OtherViewController()
        
        otherViewController.navigationItem.title = String.localized("OtherTabItem")
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [otherViewController]
        
        let otherTabItem = ESTabBarItem(ItemBounceContentView(), title: String.localized("OtherTabItem"), image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list"))
        
        navigationController.tabBarItem = otherTabItem
        
        return navigationController
        
    }()
    
    lazy var bulletinManager: BLTNItemManager = {
        let onboarding = OnboardingManager.shared.makeOnboarding()
        return BLTNItemManager(rootItem: onboarding)
    }()
    
    private var firstLaunch: FirstLaunch
    
    init() {
//        #if DEBUG
//        self.firstLaunch = FirstLaunch.alwaysFirst()
//        #else
        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: "FirstLaunch.WasLaunchedBefore")
//        #endif
        
        super.init(nibName: nil, bundle: nil)
        
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
        
        if let isEnabled = RubbishManager.shared.remindersEnabled, RubbishManager.shared.isEnabled && isEnabled {
            
            RubbishManager.shared.registerNotifications(at: RubbishManager.shared.reminderHour ?? 20, minute: RubbishManager.shared.reminderHour ?? 00)
            
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewControllers = [dashboardViewController, newsViewController, mapViewController, eventViewController, otherViewController]
        
        setupTheming()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLaunch.isFirstLaunch || !OnboardingManager.shared.userDidCompleteSetup {
            
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
    
    @objc func setupDidComplete() {
        
        OnboardingManager.shared.userDidCompleteSetup = true
        AnalyticsManager.shared.logCompletedOnboarding()
        
        self.loadData()
        
        guard let dashboardVC = dashboardViewController.children.first as? DashboardViewController else { return }
        
        dashboardVC.reloadUI()
        dashboardVC.triggerUpdate()
        
    }
    
    @objc func search() {
        
        guard let mainViewController = mapViewController.children.first as? MainViewController else { return }
        
        mainViewController.setDrawerPosition(position: .open, animated: true)
        mainViewController.contentViewController.searchBar.becomeFirstResponder()
        
    }
    
    // MARK: - Data Handling
    
    private func loadData() {
        
        if LocationManager.shared.authorizationStatus == .authorizedWhenInUse
            || LocationManager.shared.authorizationStatus == .authorizedAlways {
            
            LocationManager.shared.getCurrentLocation(completion: { (_, _) in })
            
        }
        
    }
    
}
