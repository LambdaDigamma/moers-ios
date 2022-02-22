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
    
    public static let tabs = [
        SidebarItem(
            title: AppStrings.Menu.dashboard,
            image: UIImage(systemName: "rectangle.grid.2x2"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.dashboard
        ),
        SidebarItem(
            title: AppStrings.Menu.news,
            image: UIImage(systemName: "newspaper"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.news
        ),
        SidebarItem(
            title: AppStrings.Menu.map,
            image: UIImage(systemName: "map"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.map
        ),
        SidebarItem(
            title: AppStrings.Menu.events,
            image: UIImage(systemName: "calendar"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.events
        ),
        SidebarItem(
            title: AppStrings.Menu.other,
            image: UIImage(systemName: "list.bullet"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.other
        )
    ]
    
}
