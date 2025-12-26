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
import MMEvents
import CoreLocation
import Combine
import Factory
import RubbishFeature
import MapFeature
import FuelFeature

public class AppTabBarController: AppScaffold.TabBarController {

    @LazyInjected(\.rubbishService) var rubbishService
    @LazyInjected(\.petrolService) var petrolService
    @LazyInjected(\.locationManager) var locationManager
    
    var firstLaunch: FirstLaunch
    
    let dashboard: DashboardCoordinator
    let news: NewsCoordinator
    let map: MapCoordintor
    let events: EventCoordinator
    let other: OtherCoordinator
    
    init(firstLaunch: FirstLaunch) {
        
        self.firstLaunch = firstLaunch
        
        self.dashboard = DashboardCoordinator()
        self.news = NewsCoordinator()
        self.map = MapCoordintor()
        self.events = EventCoordinator()
        self.other = OtherCoordinator()
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle -
    
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
        
        self.applyTheming()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyTheming()
        }
    }
    
    // MARK: - UI -
    
    private func applyTheming() {
        let theme = ApplicationTheme.current
        
        self.view.backgroundColor = theme.backgroundColor
        self.tabBar.tintColor = theme.accentColor
        self.tabBar.barTintColor = UIColor.systemBackground
        
        let barAppearance = UIBarAppearance()
        barAppearance.configureWithDefaultBackground()
        barAppearance.backgroundColor = UIColor.systemBackground
        
        self.tabBar.standardAppearance = UITabBarAppearance(barAppearance: barAppearance)
        self.tabBar.scrollEdgeAppearance = UITabBarAppearance(barAppearance: barAppearance)
        
        if let viewControllers = self.viewControllers {
            
            for navigationController in viewControllers {
                
                guard let nav = navigationController as? UINavigationController else { return }
                
                Styling.applyStyling(navigationController: nav, statusBarStyle: .default)
                
            }
            
        }
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = theme.navigationBarColor
        
        appearance.titleTextAttributes = [.foregroundColor: theme.accentColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: theme.accentColor]
        
        guard let controller = self.viewControllers?[2] as? UINavigationController else {
            return
        }
        
        controller.navigationBar.scrollEdgeAppearance = appearance
        
    }
    
    // MARK: - Data Handling -
    
    private func loadCurrentLocation() {
        
        locationManager.authorizationStatus.sink { (authorizationStatus: CLAuthorizationStatus) in
            if authorizationStatus == .authorizedWhenInUse {
                self.locationManager.requestCurrentLocation()
            }
        }
        .store(in: &cancellables)
        
    }
    
    // MARK: - Helper -
    
    private func setupMocked() {
        
        UserManager.shared.register(User(type: .citizen, id: nil, name: nil, description: nil))
        petrolService.petrolType = .diesel
        
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}
