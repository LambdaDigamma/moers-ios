//
//  ApplicationTheme.swift
//  MMUI
//
//  Created by Lennart Fischer on 12.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import UIKit
import SwiftUI

/// A unified theme configuration that uses iOS native colors for light/dark mode support.
/// This replaces the old Gestalt-based theming with Apple's recommended approach.
public struct ApplicationTheme {
    
    /// Shared instance using native iOS semantic colors
    public static let current = ApplicationTheme()
    
    // MARK: - Semantic Colors (automatically adapt to light/dark mode)
    
    /// Primary text color
    public var color: UIColor { UIColor.label }
    
    /// Primary background color
    public var backgroundColor: UIColor { UIColor.systemBackground }
    
    /// Accent color for interactive elements
    public var accentColor: UIColor { UIColor.systemYellow }
    
    /// Secondary text color for less prominent content
    public var decentColor: UIColor { UIColor.secondaryLabel }
    
    /// Navigation bar background color
    public var navigationBarColor: UIColor { UIColor.systemBackground }
    
    /// Tab bar background color
    public var tabBarColor: UIColor { UIColor.systemBackground }
    
    /// Card background color
    public var cardBackgroundColor: UIColor { UIColor.secondarySystemBackground }
    
    /// Separator line color
    public var separatorColor: UIColor { UIColor.separator }
    
    /// Whether cards should have shadows
    public var cardShadow: Bool { false }
    
    public var dashboardBackground: Color {
        Color(UIColor(dynamicProvider: { (traitCollection: UITraitCollection) in
            switch traitCollection.userInterfaceStyle {
                case .light:
                    return UIColor.secondarySystemBackground
                case .dark, .unspecified:
                    return UIColor.systemBackground
                @unknown default:
                    return UIColor.systemBackground
            }
        }))
    }
    
    public init() {}
    
}

public enum PresentationStyle {
    case dark
    case light
}
