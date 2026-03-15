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

public class MapCoordinator: SharedCoordinator {
    
    public let eventService: LegacyEventService
    public let entryManager: EntryManagerProtocol
    public let trackerManager: TrackerManagerProtocol
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController(),
        eventService: LegacyEventService,
        entryManager: EntryManagerProtocol,
        trackerManager: TrackerManagerProtocol
    ) {
        self.eventService = eventService
        self.entryManager = entryManager
        self.trackerManager = trackerManager
        super.init(navigationController: navigationController)
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        self.navigationController.menuItem = makeMenuItem()
        
        
        let mainViewController = MapCoordinatorViewController(
            contentViewController: MapViewController(),
            drawerViewController: DrawerFestivalMapViewController(viewModel: .init())
        )
        
        mainViewController.coordinator = self
        mainViewController.drawerViewController.coordinator = self
        
//        let mapViewController = MapViewController()
//        let contentViewController = UIStoryboard(
//            name: "ContentDrawer",
//            bundle: nil
//        ).instantiateViewController(withIdentifier: "DrawerViewController") as! DrawerViewController
//
//        let mainViewController = MapCoordinatorViewController(
//            contentViewController: mapViewController,
//            drawerViewController: contentViewController
//        )
//
//        mainViewController.coordinator = self
//        contentViewController.coordinator = self
        
        self.navigationController.viewControllers = [mainViewController]
        
    }
    
    private func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.Map.title,
            image: UIImage(systemName: "map"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.map
        )
        
    }
    
    public func showEvent(eventID: Event.ID) {
        
        guard let currentModalNavigationController = currentModalNavigationController else {
            return
        }
        
        let viewController = ModernEventDetailViewController(eventID: eventID)
        
        currentModalNavigationController.pushViewController(viewController, animated: true)
        
    }
    
}
