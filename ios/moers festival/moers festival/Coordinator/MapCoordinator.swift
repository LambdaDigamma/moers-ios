//
//  MapCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Core
import UIKit
import MMEvents
import AppScaffold
import Pulley

public class MapCoordinator: TabRepresentable {
    
    public let eventService: LegacyEventService
    public let entryManager: EntryManagerProtocol
    public let trackerManager: TrackerManagerProtocol
    
    public let mainViewController: NewMapViewController
    
    public var rootViewController: UIViewController { mainViewController }
    
    public var tabBarItem: UITabBarItem? { mainViewController.tabBarItem }
    
    public init(
        eventService: LegacyEventService,
        entryManager: EntryManagerProtocol,
        trackerManager: TrackerManagerProtocol,
        eventCoordinator: EventCoordinator? = nil
    ) {
        self.eventService = eventService
        self.entryManager = entryManager
        self.trackerManager = trackerManager
        
        self.mainViewController = NewMapViewController()
        self.mainViewController.tabBarItem = makeMenuItem().toBarItem()
        self.mainViewController.coordinator = eventCoordinator
    }
    
    private func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.Map.title,
            image: UIImage(systemName: "map"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.map
        )
        
    }
    
    public func pushPlaceDetail(placeID: Place.ID) {
        let presentationContext = VenueDetailPresentationContext.current(for: mainViewController.traitCollection)
        let viewController = VenueDetailController(placeID: placeID, presentationContext: presentationContext)
        viewController.coordinator = mainViewController.coordinator
        mainViewController.navigationController?.pushViewController(viewController, animated: true)
    }

    public func showPlaceDetail(placeID: Place.ID, showCloseButton: Bool = true) {
        let presentationContext = VenueDetailPresentationContext.current(for: mainViewController.traitCollection)
        let viewController = VenueDetailController(placeID: placeID, presentationContext: presentationContext)
        viewController.coordinator = mainViewController.coordinator
        viewController.modalPresentationStyle = .formSheet
        viewController.showCloseButton = showCloseButton

        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        mainViewController.present(navController, animated: true)
    }
    
}

extension MenuItem {
    
    public func toBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: self.title,
            image: self.image,
            selectedImage: nil
        )
        
        tabBarItem.accessibilityIdentifier = self.accessibilityIdentifier
        
        return tabBarItem
        
    }
    
}
