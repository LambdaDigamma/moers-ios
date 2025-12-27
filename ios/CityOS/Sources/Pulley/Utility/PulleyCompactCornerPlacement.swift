//
//  PulleyCompactCornerPlacement.swift
//  CityOS
//
//  Created by Lennart Fischer on 27.12.25.
//


import UIKit

/// Represents the positioning of the drawer when the `displayMode` is set to either `PulleyDisplayMode.panel` or `PulleyDisplayMode.automatic`.
/// - bottomLeft: The drawer will placed in the bottom left corner
/// - bottomRight: The drawer will placed in the bottom right corner
public enum PulleyCompactCornerPlacement {
    case bottomLeft
    case bottomRight
}
