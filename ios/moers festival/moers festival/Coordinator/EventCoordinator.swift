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
import Combine
import SwiftUI
import Factory

public class EventCoordinator: SharedCoordinator {
    
    @LazyInjected(\.pageService) var pageService
    @LazyInjected(\.legacyEventService) var eventService
    
    private var events: [MMEvents.Event] = []
    
    private let timetable: TimetableViewController
    private let adaptiveSplitViewController: AdaptiveTabSplitViewController?

    public var rootViewController: UIViewController {
        adaptiveSplitViewController ?? navigationController
    }
    
    public override init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        
        self.timetable = TimetableViewController()
        self.adaptiveSplitViewController = UIDevice.current.userInterfaceIdiom == .pad
            ? AdaptiveTabSplitViewController(
                overviewNavigationController: navigationController,
                emptyDetailFactory: Self.makeEmptyDetailViewController
            )
            : nil
        
        super.init(navigationController: navigationController)
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        self.navigationController.menuItem = makeMenuItem()
        self.adaptiveSplitViewController?.tabBarItem = self.navigationController.tabBarItem
        self.adaptiveSplitViewController?.title = self.navigationController.title
        
        self.timetable.title = String.localized("Schedule")
        
        self.timetable.onShowEvent = { (eventID: Event.ID) in
            self.showDetail(for: eventID)
        }
        
        self.navigationController.viewControllers = [timetable]
        
    }
    
    public override func pushEventDetail(eventID: Event.ID, animated: Bool = true) {
        showDetail(for: eventID, animated: animated)
    }

    func showDetail(for eventID: Event.ID, animated: Bool = true) {
        let detailFactory = { [unowned self] in
            self.makeEventDetailViewController(eventID: eventID)
        }

        if let adaptiveSplitViewController {
            adaptiveSplitViewController.setDetail(detailFactory, animated: animated)
        } else if let rootViewController = navigationController.viewControllers.first {
            navigationController.setViewControllers([rootViewController, detailFactory()], animated: false)
        }
    }

    func showOverview(animated: Bool = false) {
        if let adaptiveSplitViewController {
            adaptiveSplitViewController.showEmptyDetail(animated: animated)
        } else {
            navigationController.popToRootViewController(animated: animated)
        }
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
        
//        self.navigationController.popToRootViewController(animated: true)
//        self.eventViewController.showNext()
        
    }
    
    func showFavouriteEvents() {
        
//        self.navigationController.popToRootViewController(animated: true)
//        self.eventViewController.showFavourites()
        
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

    private func makeEventDetailViewController(eventID: Event.ID) -> UIViewController {
        let detailController = ModernEventDetailViewController(eventID: eventID)
        detailController.coordinator = self
        return detailController
    }

    private static func makeEmptyDetailViewController() -> UIViewController {
        SplitDetailPlaceholderViewController(message: String(localized: "Select an event to view its details."))
    }
    
}
