//
//  EventCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 14.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import AppScaffold
import MMEvents
// import Resolver - removed (migrated to Factory)

class EventCoordinator: Coordinator {
    
    @LazyInjected var eventService: EventService
    
    var navigationController: CoordinatedNavigationController
    var eventViewController: MMEventsViewController?
    
    init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        
        self.navigationController = navigationController
        
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
