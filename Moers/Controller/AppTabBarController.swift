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
import Gestalt
import MMAPI
import MMUI
import MMEvents
import CoreLocation
import Combine
import Resolver
import RubbishFeature
import MapFeature

public class AppTabBarController: AppScaffold.TabBarController {

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
    var petrolManager: PetrolManagerProtocol
    let eventService: EventServiceProtocol
    
    init(
        firstLaunch: FirstLaunch,
        locationManager: LocationManagerProtocol,
        petrolManager: PetrolManagerProtocol,
        cameraManager: CameraManagerProtocol,
        entryManager: EntryManagerProtocol,
        eventService: EventServiceProtocol
    ) {
        
        self.firstLaunch = firstLaunch
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        self.eventService = eventService
        
        self.dashboard = DashboardCoordinator(
            petrolManager: petrolManager
        )

        self.news = NewsCoordinator()

        self.map = MapCoordintor(
            locationManager: locationManager,
            petrolManager: petrolManager,
            cameraManager: cameraManager,
            entryManager: entryManager
        )

        self.events = EventCoordinator(
            eventService: eventService
        )

        self.other = OtherCoordinator(
            entryManager: entryManager
        )
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCurrentLocation()
        
        self.viewControllers = [
            dashboard.navigationController,
            news.navigationController,
            map.navigationController,
            events.navigationController,
            other.navigationController
        ]
        
        self.tabBar.accessibilityIdentifier = AccessibilityIdentifiers.tabBar
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTheming()
        
    }
    
    // MARK: - UI
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
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
    
    // MARK: - Helper
    
    private func setupMocked() {
        
        UserManager.shared.register(User(type: .citizen, id: nil, name: nil, description: nil))
        petrolManager.petrolType = .diesel
        
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}

extension AppTabBarController: Themeable {
    
    public typealias Theme = ApplicationTheme
    
    public func apply(theme: Theme) {
        
        self.view.backgroundColor = theme.backgroundColor
        self.tabBar.tintColor = theme.accentColor
        self.tabBar.barTintColor = UIColor.systemBackground
        
        self.tabBar.barStyle = .black
        
        let barAppearance = UIBarAppearance()
        barAppearance.configureWithDefaultBackground()
        barAppearance.backgroundColor = UIColor.systemBackground
        
        self.tabBar.standardAppearance = UITabBarAppearance(barAppearance: barAppearance)
        
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = UITabBarAppearance(barAppearance: barAppearance)
        }
        
        if let viewControllers = self.viewControllers {
            
            for navigationController in viewControllers {
                
                guard let nav = navigationController as? UINavigationController else { return }
                
                Styling.applyStyling(navigationController: nav, statusBarStyle: theme.statusBarStyle)
                
                if theme.statusBarStyle == .lightContent {
                    self.tabBar.barStyle = .black
                } else {
                    self.tabBar.barStyle = .default
                }
                
            }
            
        }
        
        if #available(iOS 13.0, *) {
            
            let appearance = UINavigationBarAppearance()
            
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = theme.navigationBarColor
            
            appearance.titleTextAttributes = [.foregroundColor : theme.accentColor]
            appearance.largeTitleTextAttributes = [.foregroundColor : theme.accentColor]
            
//            guard let controller = self.viewControllers?[safeIndex: 2] as? UINavigationController else { return }
            
            guard let controller = self.viewControllers?[2] as? UINavigationController else {
                return
            }
            
            controller.navigationBar.scrollEdgeAppearance = appearance
            
        }
        
    }
    
}
