//
//  DebugTimePanelFramePreferenceKey.swift
//  moers festival
//
//  Created by Codex on 17.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import CoreGraphics
import SwiftUI

struct DebugTimePanelFramePreferenceKey: PreferenceKey {

    static let coordinateSpaceName = "DebugTimeOverlayCoordinateSpace"
    static let defaultValue: CGRect? = nil

    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }

}

#endif
