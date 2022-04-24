//
//  EventCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 14.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import MMUI
import MMAPI
import AppScaffold
import MMEvents

class EventCoordinator: Coordinator {
    
    var navigationController: CoordinatedNavigationController
    var eventService: EventServiceProtocol
    var eventViewController: MMEventsViewController?
    
    init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        eventService: EventServiceProtocol
    ) {
        
        self.navigationController = navigationController
        self.eventService = eventService
        
        let eventViewController = MMEventsViewController()
        
        eventViewController.tabBarItem = generateTabBarItem()
        eventViewController.coordinator = self
        
        self.navigationController.coordinator = self
        self.navigationController.viewControllers = [eventViewController]
        self.eventViewController = eventViewController
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let eventsTabItem = UITabBarItem(
            title: AppStrings.Menu.events,
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar")
        )
        
        eventsTabItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.events
        
        return eventsTabItem
        
    }
    
}
