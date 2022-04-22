//
//  OtherCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 14.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMUI
import MMAPI
import AppScaffold
import EFAUI
import EFAAPI

class OtherCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    
    var otherViewController: OtherViewController?
    
    public let entryManager: EntryManagerProtocol
    public let transitService: DefaultTransitService
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        entryManager: EntryManagerProtocol
    ) {
        
        self.navigationController = navigationController
        self.entryManager = entryManager
        self.transitService = DefaultTransitService(loader: DefaultTransitService.defaultLoader())
        
        let otherViewController = OtherViewController(
            entryManager: entryManager
        )
        
        otherViewController.tabBarItem = generateTabBarItem()
        otherViewController.coordinator = self
        
        self.navigationController.coordinator = self
        self.navigationController.viewControllers = [otherViewController]
        self.otherViewController = otherViewController
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.other,
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )
        
        tabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.other
        
        return tabBarItem
        
    }
    
    // MARK: - Actions
    
    public func showBuergerfunk() {
        
        let viewController = RadioBroadcastsViewController()
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showSettings() {
        
        let settingsViewController = SettingsViewController()
        
        navigationController.pushViewController(settingsViewController, animated: true)
        
    }
    
    public func showTransportationOverview(animated: Bool = false) {
        
        self.navigationController.popToRootViewController(animated: animated)
        
        let viewController = TripConfigurationViewController()
        
        self.navigationController.pushViewController(viewController, animated: animated)
        
    }
    
    public func showTransporationSearch(data: TripSearchActivityData? = nil) {
        
        self.showTransportationOverview()
        
        let viewModel = TripSearchViewModel(transitService: transitService)
        
        if let data = data {
            viewModel.originID = data.originID
            viewModel.destinationID = data.destinationID
        }
        
        viewModel.search()
        
        let viewController = TripSearchViewController(viewModel: viewModel)
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
}
