//
//  SidebarItem.swift
//  Moers
//
//  Created by Lennart Fischer on 07.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit

public struct SidebarItem: Hashable {
    
    public let title: String?
    public let image: UIImage?
    public let accessibilityIdentifier: String?
    public let identifier = UUID()
    
    public init(
        title: String? = nil,
        image: UIImage? = nil,
        accessibilityIdentifier: String?  = nil
    ) {
        self.title = title
        self.image = image
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    public static let dashboard = SidebarItem(
        title: AppStrings.Menu.dashboard,
        image: UIImage(systemName: "rectangle.grid.2x2"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.dashboard
    )
    
    public static let news = SidebarItem(
        title: AppStrings.Menu.news,
        image: UIImage(systemName: "newspaper"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.news
    )
    
    public static let map = SidebarItem(
        title: AppStrings.Menu.map,
        image: UIImage(systemName: "map"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.map
    )
    
    public static let events = SidebarItem(
        title: AppStrings.Menu.events,
        image: UIImage(systemName: "calendar"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.events
    )
    
    public static let other = SidebarItem(
        title: AppStrings.Menu.other,
        image: UIImage(systemName: "list.bullet"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.other
    )
    
    public static let tabs = [
        Self.dashboard,
        Self.news,
        Self.map,
        Self.events,
        Self.other
    ]
    
}
