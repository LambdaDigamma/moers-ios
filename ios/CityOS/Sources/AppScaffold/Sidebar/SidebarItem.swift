//
//  SidebarItem.swift
//  
//
//  Created by Lennart Fischer on 31.03.22.
//

#if canImport(UIKit)

import UIKit

nonisolated public struct SidebarItem: Hashable, Equatable, Sendable {
    
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

#endif
