//
//  AppSplitViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 31.03.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import UIKit
import AppScaffold
import MMEvents
import SwiftUI

public class AppSplitViewController: AppScaffold.SplitViewController {
    
    public let news: NewsCoordinator
    public let live: LiveCoordinator
    public let map: MapCoordinator
    public let event: EventCoordinator
    public let other: OtherCoordinator
    
    internal let tabController: TabBarController
    
    private let launchInterceptor: LaunchInterceptor
    
    public init(
        firstLaunch: FirstLaunch,
        eventService: LegacyEventService,
        entryManager: EntryManagerProtocol,
        trackerManager: TrackerManagerProtocol
    ) {
        
        self.news = NewsCoordinator()
        self.live = LiveCoordinator()
        self.event = EventCoordinator()
        self.map = MapCoordinator(
            eventService: eventService,
            entryManager: entryManager,
            trackerManager: trackerManager,
            eventCoordinator: event
        )
        self.other = OtherCoordinator()
        
        let tabRepresentables: [any AppScaffold.TabRepresentable] = [
            news,
//            live,
            map,
            event,
            other
        ]
        
        self.tabController = TabBarController(
            eventService: eventService,
            entryManager: entryManager,
            trackerManager: trackerManager
        )
        
        let secondaryRootViewControllers = tabRepresentables.map(\.rootViewController)
        
        self.launchInterceptor = LaunchInterceptor(firstLaunch: firstLaunch)
        
        super.init(
            firstLaunch: firstLaunch,
            style: .doubleColumn,
            sidebarController: AppSidebarViewController(),
            compactController: tabController,
            secondaryRootViewControllers: secondaryRootViewControllers
        )
        
        self.sidebarItems = SidebarItem.tabs
        self.launchInterceptor.viewController = self
        self.configureSplitController()
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemBackground
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.launchInterceptor.onAppear()
        
    }
    
}
