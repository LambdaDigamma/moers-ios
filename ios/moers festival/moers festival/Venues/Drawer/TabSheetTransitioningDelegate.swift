//
//  TabSheetTransitioningDelegate.swift
//  moers festival
//
//  Created by Lennart Fischer on 20.03.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import UIKit

class TabSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    weak var sheetDelegate: UISheetPresentationControllerDelegate?

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {

        let nearLargeIdentifier = UISheetPresentationController.Detent.Identifier("nearLarge")

        let sheet = TabSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            source: source
        )

        sheet.detents = [
            .custom(identifier: .init("collapsed")) { _ in 120 },
            .medium(),
            .custom(identifier: nearLargeIdentifier) { context in
                context.maximumDetentValue - 0.1
            }
        ]

        sheet.largestUndimmedDetentIdentifier = nearLargeIdentifier
        sheet.prefersGrabberVisible = true
//        sheet.preferredCornerRadius = 48
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        
        if let sheetDelegate {
            sheet.delegate = sheetDelegate
        }

        return sheet
    }
}
