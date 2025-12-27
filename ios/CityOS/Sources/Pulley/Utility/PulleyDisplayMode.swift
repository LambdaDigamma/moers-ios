//
//  PulleyDisplayMode.swift
//  CityOS
//
//  Created by Lennart Fischer on 27.12.25.
//


import UIKit

/// Represents the current display mode for Pulley
///
/// - panel: Show as a floating panel (replaces: leftSide)
/// - drawer: Show as a bottom drawer (replaces: bottomDrawer)
/// - compact: Show as a compacted bottom drawer (support for iPhone SE size class)
/// - automatic: Determine it based on device / orientation / size class (like Maps.app)
public enum PulleyDisplayMode {
    case panel
    case drawer
    case compact
    case automatic
}
