//
//  SidebarItem.swift
//  Moers
//
//  Created by Lennart Fischer on 07.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit
import AppScaffold
import Core

public extension SidebarItem {
    
    static let dashboard = SidebarItem(
        title: AppStrings.Menu.dashboard,
        image: UIImage(systemName: "rectangle.grid.2x2"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.dashboard
    )
    
    static let news = SidebarItem(
        title: AppStrings.Menu.news,
        image: UIImage(systemName: "newspaper"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.news
    )
    
    static let map = SidebarItem(
        title: AppStrings.Menu.map,
        image: UIImage(systemName: "map"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.map
    )
    
    static let events = SidebarItem(
        title: AppStrings.Menu.events,
        image: UIImage(systemName: "calendar"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.events
    )
    
    static let other = SidebarItem(
        title: AppStrings.Menu.other,
        image: UIImage(systemName: "list.bullet"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.other
    )
    
    static let tabs = [
        Self.dashboard,
        Self.news,
        Self.map,
        Self.events,
        Self.other
    ]
    
}
