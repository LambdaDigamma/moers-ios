//
//  Navigation.swift
//  moers festival
//
//  Created by Lennart Fischer on 30.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import Core

public enum TabIndices: Int {
    
    case news = 0
    case maps = 1
    case userSchedule = 2
    case events = 3
    case other = 4
    
}

public extension SidebarItem {
    
    static let news = SidebarItem(
        title: AppStrings.News.title,
        image: UIImage(systemName: "newspaper"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.news
    )
    
    static let map = SidebarItem(
        title: AppStrings.Map.title,
        image: UIImage(systemName: "map"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.map
    )
    
    static let live = SidebarItem(
        title: AppStrings.Live.title,
        image: UIImage(systemName: "play.circle"),
        accessibilityIdentifier: "AccessibilityIdentifiers.Menu.live"
    )
    
    static let events = SidebarItem(
        title: AppStrings.Events.title,
        image: UIImage(systemName: "calendar"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.events
    )
    
    static let other = SidebarItem(
        title: AppStrings.Info.title,
        image: UIImage(systemName: "list.bullet"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.other
    )
    
    static let tabs = [
        Self.news,
//        Self.live,
        Self.map,
        Self.events,
        Self.other
    ]
    
}
