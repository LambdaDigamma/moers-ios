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
import Factory

class EventCoordinator: Coordinator {
    
    @LazyInjected(\.eventService) var eventService
    
    var navigationController: CoordinatedNavigationController
    var eventViewController: UIViewController?
    
    init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        
        self.navigationController = navigationController
        
        // Use the appropriate version based on iOS availability
        let eventViewController: UIViewController & TabBarItemProvider & CoordinatorAssignable
        if #available(iOS 26.0, *) {
            let vc = MMEventsViewController()
            vc.coordinator = self
            eventViewController = vc
        } else {
            let vc = MMEventsViewController_Legacy()
            vc.coordinator = self
            eventViewController = vc
        }
        
        eventViewController.tabBarItem = generateTabBarItem()
        
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

// Protocol to make both versions compatible with the coordinator
protocol TabBarItemProvider {
    var tabBarItem: UITabBarItem! { get set }
}

protocol CoordinatorAssignable {
    var coordinator: EventCoordinator? { get set }
}

extension MMEventsViewController_Legacy: TabBarItemProvider, CoordinatorAssignable {}

@available(iOS 26.0, *)
extension MMEventsViewController: TabBarItemProvider, CoordinatorAssignable {}
