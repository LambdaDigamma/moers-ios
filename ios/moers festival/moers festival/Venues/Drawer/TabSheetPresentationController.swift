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

    init(presentedViewController: UIViewController, presenting: UIViewController?, source: UIViewController) {
        self.sourceViewController = source
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    private var tabBarHeight: CGFloat {
        var vc: UIViewController? = sourceViewController
        while let current = vc {
            if let tabBarController = current as? UITabBarController {
                return tabBarController.tabBar.frame.height
            }
            vc = current.parent
        }
        return 0
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        adjustContainerFrame()
        containerView?.clipsToBounds = true
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        guard completed, let containerView = containerView else { return }

        let targetSuperview = presentingViewController.view!

        var sheetAncestor: UIView? = containerView
        while let parent = sheetAncestor?.superview, parent != targetSuperview {
            sheetAncestor = parent
        }

        if let sheetAncestor, sheetAncestor.superview == targetSuperview {
            targetSuperview.sendSubviewToBack(sheetAncestor)
        }
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        adjustContainerFrame()
    }

    private func adjustContainerFrame() {
//        guard let containerView = containerView else { return }
//        let tabHeight = tabBarHeight
//        guard tabHeight > 0 else { return }
//
//        var frame = containerView.superview?.bounds ?? containerView.frame
//        frame.size.height -= tabHeight
//        containerView.frame = frame
    }
}
