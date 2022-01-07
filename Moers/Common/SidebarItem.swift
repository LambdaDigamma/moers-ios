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
}
