//
//  DebugTimeOverlayState.swift
//  moers festival
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import Combine
import CoreGraphics

final class DebugTimeOverlayState: ObservableObject {

    @Published var isControlVisible = false
    @Published var interactiveFrame: CGRect?

    func toggleControlVisibility() {
        isControlVisible.toggle()
    }

}

#endif
