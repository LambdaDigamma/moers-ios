//
//  DebugTimeOverlayWindowController.swift
//  moers festival
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import SwiftUI
import UIKit

final class DebugTimeOverlayWindowController {

    private let overlayState = DebugTimeOverlayState()
    private let debugTimeController: DebugTimeController
    private let overlayWindow: UIWindow
    private weak var gestureSourceView: UIView?

    init(
        windowScene: UIWindowScene,
        sourceWindow: UIWindow,
        debugTimeController: DebugTimeController
    ) {
        self.debugTimeController = debugTimeController
        self.overlayWindow = DebugTimePassThroughWindow(windowScene: windowScene)
        self.gestureSourceView = sourceWindow

        configureOverlayWindow()
        installGestureRecognizer(on: sourceWindow)
    }

    private func configureOverlayWindow() {
        let control = DebugTimeTravelControl(
            controller: debugTimeController,
            overlayState: overlayState
        )

        let hostingController = UIHostingController(rootView: control)
        hostingController.view.backgroundColor = .clear

        overlayWindow.rootViewController = hostingController
        overlayWindow.backgroundColor = .clear
        overlayWindow.windowLevel = .alert + 1
        overlayWindow.isHidden = false

        if let passThroughWindow = overlayWindow as? DebugTimePassThroughWindow {
            passThroughWindow.interactiveFrameProvider = { [weak overlayState] in
                overlayState?.interactiveFrame
            }
        }
    }

    private func installGestureRecognizer(on view: UIView) {
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(toggleControl)
        )
        recognizer.numberOfTouchesRequired = 3
        recognizer.numberOfTapsRequired = 3
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false

        view.addGestureRecognizer(recognizer)
    }

    @objc private func toggleControl() {
        overlayState.toggleControlVisibility()
    }

}

#endif
