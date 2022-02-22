//
//  MainSplitViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 06.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit

/// The main view controller which holds
public class MainSplitViewController: UISplitViewController {
    
    public init(tabController: TabBarController) {
        super.init(style: .doubleColumn)
        
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        self.showsSecondaryOnlyButton = true
        self.presentsWithGesture = true
        
        if #available(iOS 14.5, *) {
            self.displayModeButtonVisibility = .always
        }
        
        let sidebarController = SidebarViewController(coordinators: [
            tabController.dashboard,
            tabController.news,
            tabController.map,
            tabController.events,
            tabController.other
        ])
        
        self.setViewController(tabController, for: .compact)
        self.setViewController(sidebarController, for: .primary)

//        self.setViewController(, for: .primary)
//        self.setViewController(, for: .secondary
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
