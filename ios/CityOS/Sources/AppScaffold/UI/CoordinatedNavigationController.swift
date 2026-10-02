//
//  CoordinatedNavigationController.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

#if canImport(UIKit) && os(iOS)

import UIKit

@available(iOS 14.0, *)
open class CoordinatedNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    open weak var coordinator: Coordinator?
    
    open var menuItem: MenuItem? {
        
        didSet {
            
            guard let menuItem = menuItem else {
                tabBarItem = nil
                title = nil
                return
            }
            
            restorePersistentTabBarItem()
            title = menuItem.title
            
        }
        
    }
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureNavigationDelegate()
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configureNavigationDelegate()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureNavigationDelegate()
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        restorePersistentTabBarItem()
    }

    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        restorePersistentTabBarItem()
    }

    open override func show(_ vc: UIViewController, sender: Any?) {
        super.show(vc, sender: sender)
        restorePersistentTabBarItem()
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        restorePersistentTabBarItem()
    }

    private func configureNavigationDelegate() {
        delegate = self
    }

    private func restorePersistentTabBarItem() {
        guard let menuItem else { return }

        // UIKit keeps references to tab items. Preserve the item during navigation.
        let item = tabBarItem ?? UITabBarItem()
        item.title = menuItem.title
        item.image = menuItem.image
        item.accessibilityLabel = menuItem.title
        item.accessibilityIdentifier = menuItem.accessibilityIdentifier

        if tabBarItem !== item {
            tabBarItem = item
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

#endif
