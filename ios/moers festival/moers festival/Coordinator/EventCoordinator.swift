//
//  EventCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import MMEvents
import MMPages
import MMEvents
import AppScaffold
import Resolver
import Combine
import SwiftUI

public class EventCoordinator: SharedCoordinator {
    
    @LazyInjected var pageService: PageService
    @LazyInjected var eventService: LegacyEventService
    
    public let eventManager: LegacyEventService
    private var events: [MMEvents.Event] = []
    private var eventViewController = MFEventsViewController()
    
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        eventService: LegacyEventService
    ) {
        self.eventManager = eventService
        super.init(navigationController: navigationController)
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        self.navigationController.menuItem = makeMenuItem()
        
        let tabBarItem = UITabBarItem(
            title: self.navigationController.menuItem?.title,
            image: self.navigationController.menuItem?.image,
            selectedImage: nil
        )
        
        eventViewController.coordinator = self
        eventViewController.tabBarItem = tabBarItem
        eventViewController.title = String.localized("EventsTabItem")
        
        let timetable = TimetableViewController()
        
        timetable.title = String.localized("EventsTabItem")
        
        timetable.onShowEvent = { (eventID: Event.ID) in
            self.showDetail(for: eventID)
        }
        
//        self.navigationController.viewControllers = [eventViewController]
        self.navigationController.viewControllers = [timetable]
        
    }
    
    func setEvents(_ events: [MMEvents.Event]) {
        
        self.events = events
        
    }
    
    func showDetail(for eventID: Event.ID) {
        
//        guard let event = eventViewController.events
//            .map({ $0.model })
//            .filter({ $0.id == eventID })
//            .first else { return }
//
        self.navigationController.popToRootViewController(animated: true)
        
        let detailController = ModernEventDetailViewController(
            eventID: eventID,
            eventService: eventService
        )

        detailController.coordinator = self

        self.navigationController.pushViewController(detailController, animated: true)
        
        
//        self.showEventDetailViewController(with: event)
        
    }
    
    func showEventDetailViewController(with event: MMEvents.Event) {
        
//        let detailController = ModernEventDetailViewController(
//            eventID: event.id,
//            eventService: eventService
//        )
//
//        detailController.coordinator = self
//
//        self.navigationController.pushViewController(detailController, animated: true)
        
    }
    
    func showNextEvents() {
        
        self.navigationController.popToRootViewController(animated: true)
        self.eventViewController.showNext()
        
    }
    
    func showFavouriteEvents() {
        
        self.navigationController.popToRootViewController(animated: true)
        self.eventViewController.showFavourites()
        
    }
    
    // MARK: - Detail Controllers -
    
    private func showPage(for pageID: Page.ID) {
        
    }
    
    private func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.Events.title,
            image: UIImage(systemName: "calendar.badge.clock"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.events
        )
        
    }
    
}
