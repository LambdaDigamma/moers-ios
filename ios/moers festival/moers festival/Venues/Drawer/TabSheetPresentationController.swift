//
//  TabSheetPresentationController.swift
//  moers festival
//
//  Created by Lennart Fischer on 20.03.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import UIKit

class TabSheetPresentationController: UISheetPresentationController {
    
    private weak var sourceViewController: UIViewController?
    
    init(
        presentedViewController: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) {
        self.sourceViewController = source
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = containerView else { return }
        
        containerView.removeFromSuperview()
        
        sourceViewController?.view.addSubview(containerView)
        
    }
    
}
