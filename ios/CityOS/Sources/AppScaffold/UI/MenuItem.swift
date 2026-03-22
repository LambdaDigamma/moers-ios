//
//  MenuItem.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

#if canImport(UIKit) && os(iOS)

import UIKit

@available(iOS 14.0, *)
public struct MenuItem: Hashable, Identifiable {
    public let title: String?
    public let image: UIImage?
    public let accessibilityIdentifier: String?
    public let id = UUID()
    
    public init(title: String?, image: UIImage?, accessibilityIdentifier: String? = nil) {
        self.title = title
        self.image = image
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

#endif

#if canImport(AppKit)
import AppKit

@available(macOS 10.15, *)
public struct MenuItem: Hashable, Identifiable {
    public let title: String?
    public let image: NSImage?
    public let accessibilityIdentifier: String?
    public let id = UUID()
    
    public init(title: String?, image: NSImage?, accessibilityIdentifier: String? = nil) {
        self.title = title
        self.image = image
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

#endif
