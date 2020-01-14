//
//  EventCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 14.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMUI
import MMAPI

class EventCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    var eventManager: EventManagerProtocol
    var eventViewController: MMEventsViewController?
    
    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
         eventManager: EventManagerProtocol) {
        
        self.navigationController = navigationController
        self.eventManager = eventManager
        
        let eventViewController = MMEventsViewController()
        
        eventViewController.tabBarItem = generateTabBarItem()
        eventViewController.coordinator = self
        
        self.navigationController.coordinator = self
        self.navigationController.viewControllers = [eventViewController]
        self.eventViewController = eventViewController
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabControllerFactory = TabControllerFactory()
        
        let eventsTab = tabControllerFactory.buildTabItem(
            using: ItemBounceContentView(),
            title: String.localized("Events"),
            image: #imageLiteral(resourceName: "calendar"),
            accessibilityLabel: String.localized("Events"),
            accessibilityIdentifier: "TabEvents")
        
        return eventsTab
        
    }
    
}
