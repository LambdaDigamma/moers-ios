//
//  AdaptiveTabSplitViewController.swift
//  moers festival
//
//  Created by Codex on 04.04.26.
//

import UIKit

final class AdaptiveTabSplitViewController: UISplitViewController, UINavigationControllerDelegate, UISplitViewControllerDelegate {
    
    private let overviewNavigationController: UINavigationController
    private let detailNavigationController = UINavigationController()
    private let emptyDetailFactory: () -> UIViewController
    
    private var currentDetailFactory: (() -> UIViewController)?
    
    init(
        overviewNavigationController: UINavigationController,
        emptyDetailFactory: @escaping () -> UIViewController
    ) {
        self.overviewNavigationController = overviewNavigationController
        self.emptyDetailFactory = emptyDetailFactory
        super.init(style: .doubleColumn)
        
        self.tabBarItem = overviewNavigationController.tabBarItem
        self.title = overviewNavigationController.title
        self.overviewNavigationController.delegate = self
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .tile
        presentsWithGesture = false
        primaryBackgroundStyle = .sidebar
        minimumPrimaryColumnWidth = 340
        maximumPrimaryColumnWidth = 420
        preferredPrimaryColumnWidthFraction = 0.32
        
        detailNavigationController.navigationBar.prefersLargeTitles = true
        
        setViewController(overviewNavigationController, for: .primary)
        setViewController(detailNavigationController, for: .secondary)
        detailNavigationController.setViewControllers([makeRegularDetailRootViewController()], animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isCollapsed else { return }
        guard let currentDetailFactory else { return }
        guard overviewNavigationController.viewControllers.count == 1 else { return }
        
        showDetailInCompactLayout(currentDetailFactory(), animated: false)
    }
    
    func setDetail(_ detailFactory: @escaping () -> UIViewController, animated: Bool = true) {
        currentDetailFactory = detailFactory
        guard isViewLoaded else { return }
        
        if isCollapsed {
            showDetailInCompactLayout(detailFactory(), animated: animated)
        } else {
            detailNavigationController.setViewControllers([detailFactory()], animated: animated)
        }
    }
    
    func showEmptyDetail(animated: Bool = false) {
        currentDetailFactory = nil
        guard isViewLoaded else { return }
        
        if isCollapsed {
            overviewNavigationController.popToRootViewController(animated: animated)
        } else {
            detailNavigationController.setViewControllers([emptyDetailFactory()], animated: animated)
        }
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard navigationController === overviewNavigationController else { return }
        guard isCollapsed else { return }
        guard let rootViewController = overviewNavigationController.viewControllers.first else { return }
        
        if viewController === rootViewController {
            currentDetailFactory = nil
        }
    }
    
    private func showDetailInCompactLayout(_ detailViewController: UIViewController, animated: Bool) {
        guard let rootViewController = overviewNavigationController.viewControllers.first else { return }
        
        if overviewNavigationController.viewControllers.count > 1 {
            overviewNavigationController.setViewControllers([rootViewController, detailViewController], animated: false)
        } else {
            overviewNavigationController.pushViewController(detailViewController, animated: animated)
        }
    }
    
    private func makeRegularDetailRootViewController() -> UIViewController {
        currentDetailFactory?() ?? emptyDetailFactory()
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        guard let primaryNavigationController = primaryViewController as? UINavigationController,
              let rootViewController = primaryNavigationController.viewControllers.first else {
            return false
        }
        
        guard let currentDetailFactory else {
            primaryNavigationController.setViewControllers([rootViewController], animated: false)
            return true
        }
        
        primaryNavigationController.setViewControllers([rootViewController, currentDetailFactory()], animated: false)
        return true
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        separateSecondaryViewControllerFrom primaryViewController: UIViewController
    ) -> UIViewController? {
        guard let primaryNavigationController = primaryViewController as? UINavigationController,
              let rootViewController = primaryNavigationController.viewControllers.first else {
            return nil
        }
        
        primaryNavigationController.setViewControllers([rootViewController], animated: false)
        
        if let currentDetailFactory {
            detailNavigationController.setViewControllers([currentDetailFactory()], animated: false)
        } else {
            detailNavigationController.setViewControllers([emptyDetailFactory()], animated: false)
        }
        
        return detailNavigationController
    }
}


