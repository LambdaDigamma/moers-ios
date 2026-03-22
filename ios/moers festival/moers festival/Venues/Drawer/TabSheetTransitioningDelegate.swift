//
//  TabSheetTransitioningDelegate.swift
//  moers festival
//
//  Created by Lennart Fischer on 20.03.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import UIKit

extension UISheetPresentationController.Detent.Identifier {
    
    static let small = UISheetPresentationController.Detent.Identifier("small")
    static let nearFull = UISheetPresentationController.Detent.Identifier("nearFull")
    
}

class TabSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    weak var sheetDelegate: UISheetPresentationControllerDelegate?
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        
        let sheet = TabSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            source: source
        )
        
        sheet.detents = [
            .custom(identifier: .small) { _ in
                return 105
            },
            .medium(),
            .custom(identifier: .nearFull, resolver: { context in
                context.maximumDetentValue
//                source.view.bounds.height * 0.9
            })
        ]
        
        sheet.selectedDetentIdentifier = .small
        sheet.largestUndimmedDetentIdentifier = .nearFull
        sheet.prefersGrabberVisible = true
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        
        if let sheetDelegate {
            sheet.delegate = sheetDelegate
        }
        
        return sheet
    }
    
}
