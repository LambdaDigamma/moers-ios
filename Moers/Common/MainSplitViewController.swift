//
//  MainSplitViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 06.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit
import AppScaffold
import MMAPI
import MMEvents
import OSLog

/// The main view controller which holds
public class MainSplitViewController: UISplitViewController, SidebarViewControllerDelegate, UISplitViewControllerDelegate {
    
    private let logger: Logger = Logger(.default)
    
    let dashboard: DashboardCoordinator
    let news: NewsCoordinator
    let map: MapCoordintor
    let events: EventCoordinator
    let other: OtherCoordinator
    
    internal let tabController: TabBarController
    internal let sidebarController: SidebarViewController
    internal let secondaryRootViewControllers: [UIViewController]
    
    public var onChangeTraitCollection: ((UITraitCollection) -> Void)?
    
    public init(
        firstLaunch: FirstLaunch,
        locationManager: LocationManagerProtocol,
        petrolManager: PetrolManagerProtocol,
        cameraManager: CameraManagerProtocol,
        entryManager: EntryManagerProtocol,
        parkingLotManager: ParkingLotManagerProtocol,
        eventService: EventServiceProtocol
    ) {
        
        self.dashboard = DashboardCoordinator(
            petrolManager: petrolManager
        )
        
        self.news = NewsCoordinator()
        
        self.map = MapCoordintor(
            locationManager: locationManager,
            petrolManager: petrolManager,
            cameraManager: cameraManager,
            entryManager: entryManager,
            parkingLotManager: parkingLotManager
        )
        
        self.events = EventCoordinator(
            eventService: eventService
        )
        
        self.other = OtherCoordinator(
            entryManager: entryManager
        )
        
        let coordinators: [Coordinator] = [
            dashboard,
            news,
            map,
            events,
            other
        ]
        
        self.tabController = TabBarController(
            firstLaunch: firstLaunch,
            locationManager: locationManager,
            petrolManager: petrolManager,
            cameraManager: cameraManager,
            entryManager: entryManager,
            parkingLotManager: parkingLotManager,
            eventService: eventService
        )
        
        self.secondaryRootViewControllers = coordinators.map({ coordinator in
            coordinator.navigationController
        })
        
        self.sidebarController = SidebarViewController()
        
        super.init(style: .doubleColumn)
        
        self.configureSplitController()
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSplitController() {
        
        self.sidebarController.delegate = self
        
        self.delegate = self
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        self.showsSecondaryOnlyButton = true
        self.presentsWithGesture = true
        
        if #available(iOS 14.5, *) {
            self.displayModeButtonVisibility = .always
        }
        
        self.setViewController(tabController, for: .compact)
        self.setViewController(sidebarController, for: .primary)
        self.setViewController(secondaryRootViewControllers[0], for: .secondary)
        
    }
    
    // MARK: - Sidebar Handling -
    
    public func sidebar(_ sidebarViewController: SidebarViewController, didSelectTabItem item: SidebarItem) {
        
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        
        if let index = SidebarItem.tabs.firstIndex(of: item) {
            let indexPath = IndexPath(item: index, section: 0)
            self.setViewController(secondaryRootViewControllers[indexPath.row], for: .secondary)
        }
        
    }
    
    public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        
        self.logger.info("MainSplitViewController changes to \(displayMode.rawValue, privacy: .public)")
        
    }
    
    public func switchToToday() {
        selectSidebarItem(.dashboard)
    }
    
    public func switchToNews() {
        selectSidebarItem(.news)
    }
    
    internal func selectSidebarItem(_ item: SidebarItem) {
        
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        
        if let index = SidebarItem.tabs.firstIndex(of: item) {
            self.sidebarController.selectIndex(index)
            self.setViewController(secondaryRootViewControllers[index], for: .secondary)
        }
        
    }
    
    public var displayCompact: Bool {
        return self.traitCollection.horizontalSizeClass == .compact
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if let previousTraitCollection = previousTraitCollection {
            
            if previousTraitCollection.horizontalSizeClass != traitCollection.horizontalSizeClass &&
                traitCollection.userInterfaceIdiom == .pad {
                onChangeTraitCollection?(traitCollection)
            }
            
        }
        
    }
    
}
