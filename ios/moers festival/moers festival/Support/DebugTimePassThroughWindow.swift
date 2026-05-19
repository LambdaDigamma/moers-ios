//
//  DebugTimePassThroughWindow.swift
//  moers festival
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import UIKit

final class DebugTimePassThroughWindow: UIWindow {

    var interactiveFrameProvider: (() -> CGRect?)?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView === rootViewController?.view {
            if interactiveFrameProvider?()?.contains(point) == true {
                return hitView
            }

            return nil
        }

        return hitView
    }

}

#endif
