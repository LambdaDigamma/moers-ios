//
//  PulleyPanelCornerPlacement.swift
//  CityOS
//
//  Created by Lennart Fischer on 27.12.25.
//


import UIKit

/// Represents the positioning of the drawer when the `displayMode` is set to either `PulleyDisplayMode.panel` or `PulleyDisplayMode.automatic`.
///
/// - topLeft: The drawer will placed in the upper left corner
/// - topRight: The drawer will placed in the upper right corner
/// - bottomLeft: The drawer will placed in the bottom left corner
/// - bottomRight: The drawer will placed in the bottom right corner
public enum PulleyPanelCornerPlacement {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}