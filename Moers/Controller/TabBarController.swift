//
//  TabBarController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BulletinBoard
import Gestalt
import ESTabBarController

class TabBarController: ESTabBarController, UITabBarControllerDelegate {

    lazy var dashboardViewController: UIViewController = {
        
        let dashboardViewController = UIViewController()
        
        dashboardViewController.navigationItem.title = String.localized("DashboardTabItem")
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [dashboardViewController]
        
        let dashboardTabItem = ESTabBarItem(ItemBounceContentView(), title: String.localized("DashboardTabItem"), image: #imageLiteral(resourceName: "dashboard"), selectedImage: #imageLiteral(resourceName: "dashboard"))
        
        navigationController.tabBarItem = dashboardTabItem
        
        return navigationController
        
    }()
    
    lazy var mapViewController: UIViewController = {
        
        let mapViewController = RebuildMapViewController()
        let contentViewController = RebuildContentViewController()
        
        let mainViewController = MainViewController(contentViewController: mapViewController, drawerViewController: contentViewController)
        
        mainViewController.navigationItem.title = String.localized("MapTabItem")
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [mainViewController]
        
        let mapTabItem = ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "map_marker"), selectedImage: #imageLiteral(resourceName: "map_marker"))
        
        navigationController.tabBarItem = mapTabItem
        
        return navigationController
        
    }()
    
    lazy var otherViewController: UIViewController = {
        
        let otherViewController = UIViewController()
        
        otherViewController.navigationItem.title = String.localized("OtherTabItem")
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [otherViewController]
        
        let otherTabItem = ESTabBarItem(ItemBounceContentView(), title: String.localized("OtherTabItem"), image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list"))
        
        navigationController.tabBarItem = otherTabItem
        
        return navigationController
        
    }()
    
    lazy var bulletinManager: BulletinManager = {
        let introPage = BulletinDataSource.makeIntroPage()
        return BulletinManager(rootItem: introPage)
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

        self.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewControllers = [dashboardViewController, mapViewController, otherViewController]
        
        setupTheming()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLaunch.isFirstLaunch || !BulletinDataSource.userDidCompleteSetup {
            
//            showBulletin()
            
        }
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        
        if let item = item as? ESTabBarItem {
            
            if item.contentView is MapItemContentView {
                
                viewControllers?[1].tabBarItem = ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "search"), selectedImage: #imageLiteral(resourceName: "search"))
                
            } else {
                
                viewControllers?[1].tabBarItem = ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "map_marker"), selectedImage: #imageLiteral(resourceName: "map_marker"))
                
            }
            
        }
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            UIApplication.shared.statusBarStyle = theme.statusBarStyle
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.tabBar.tintColor = theme.accentColor
            themeable.tabBar.barTintColor = theme.navigationColor
            themeable.tabBar.isTranslucent = false
            themeable.bulletinManager.backgroundColor = theme.backgroundColor
            themeable.bulletinManager.hidesHomeIndicator = false
            themeable.bulletinManager.cardPadding = .compact
            
            if let viewControllers = themeable.viewControllers {
                
                for navigationController in viewControllers {
                    
                    guard let nav = navigationController as? UINavigationController else { return }
                    
                    nav.navigationBar.barTintColor = theme.navigationColor
                    nav.navigationBar.tintColor = theme.accentColor
                    nav.navigationBar.prefersLargeTitles = true
                    nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.accentColor]
                    nav.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.accentColor]
                    
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
        bulletinManager.prepareAndPresent(above: self)
        
    }
    
    @objc func setupDidComplete() {
        
        BulletinDataSource.userDidCompleteSetup = true
        
    }
    
}
