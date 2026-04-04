//
//  AdaptiveTabSplitViewController.swift
//  moers festival
//
//  Created by Codex on 04.04.26.
//

import UIKit

final class AdaptiveTabSplitViewController: UIViewController, UINavigationControllerDelegate {

    private enum LayoutMode {
        case compact
        case split
    }

    private let splitThreshold: CGFloat
    private let overviewNavigationController: UINavigationController
    private let detailNavigationController = UINavigationController()
    private let splitContainerViewController = UISplitViewController(style: .doubleColumn)
    private let primaryPlaceholderViewController = UIViewController()
    private let emptyDetailFactory: () -> UIViewController

    private var currentDetailFactory: (() -> UIViewController)?
    private var embeddedController: UIViewController?
    private var layoutMode: LayoutMode?

    var isSplitActive: Bool {
        layoutMode == .split
    }

    init(
        overviewNavigationController: UINavigationController,
        splitThreshold: CGFloat = 900,
        emptyDetailFactory: @escaping () -> UIViewController
    ) {
        self.overviewNavigationController = overviewNavigationController
        self.splitThreshold = splitThreshold
        self.emptyDetailFactory = emptyDetailFactory
        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = overviewNavigationController.tabBarItem
        self.title = overviewNavigationController.title
        self.overviewNavigationController.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        splitContainerViewController.preferredDisplayMode = .oneBesideSecondary
        splitContainerViewController.preferredSplitBehavior = .tile
        splitContainerViewController.presentsWithGesture = false
        splitContainerViewController.minimumPrimaryColumnWidth = 340
        splitContainerViewController.maximumPrimaryColumnWidth = 420
        splitContainerViewController.preferredPrimaryColumnWidthFraction = 0.32
        splitContainerViewController.setViewController(primaryPlaceholderViewController, for: .primary)
        detailNavigationController.navigationBar.prefersLargeTitles = true
        splitContainerViewController.setViewController(detailNavigationController, for: .secondary)

        updateLayoutIfNeeded(force: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutIfNeeded()
    }

    func setDetail(_ detailFactory: @escaping () -> UIViewController, animated: Bool = true) {
        currentDetailFactory = detailFactory

        switch desiredLayoutMode() {
        case .split:
            layoutMode = .split
            detailNavigationController.setViewControllers([detailFactory()], animated: false)
            if embeddedController !== splitContainerViewController {
                updateLayoutIfNeeded(force: true)
            }
        case .compact:
            layoutMode = .compact
            showDetailInCompactLayout(detailFactory(), animated: animated)
            if embeddedController !== overviewNavigationController {
                updateLayoutIfNeeded(force: true)
            }
        }
    }

    func showEmptyDetail(animated: Bool = false) {
        currentDetailFactory = nil

        switch desiredLayoutMode() {
        case .split:
            layoutMode = .split
            detailNavigationController.setViewControllers([emptyDetailFactory()], animated: animated)
            if embeddedController !== splitContainerViewController {
                updateLayoutIfNeeded(force: true)
            }
        case .compact:
            layoutMode = .compact
            overviewNavigationController.popToRootViewController(animated: animated)
            if embeddedController !== overviewNavigationController {
                updateLayoutIfNeeded(force: true)
            }
        }
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard navigationController === overviewNavigationController else { return }
        guard layoutMode == .compact else { return }
        guard let rootViewController = overviewNavigationController.viewControllers.first else { return }

        if viewController === rootViewController {
            currentDetailFactory = nil
        }
    }

    private func updateLayoutIfNeeded(force: Bool = false) {
        let newLayoutMode = desiredLayoutMode()

        guard force || newLayoutMode != layoutMode else {
            return
        }

        layoutMode = newLayoutMode

        switch newLayoutMode {
        case .compact:
            applyCompactLayout()
        case .split:
            applySplitLayout()
        }
    }

    private func desiredLayoutMode() -> LayoutMode {
        let width = resolvedWidth()
        return traitCollection.userInterfaceIdiom == .pad && width >= splitThreshold ? .split : .compact
    }

    private func resolvedWidth() -> CGFloat {
        if view.bounds.width > 0 {
            return view.bounds.width
        }

        if let parentWidth = parent?.view.bounds.width, parentWidth > 0 {
            return parentWidth
        }

        return UIScreen.main.bounds.width
    }

    private func applyCompactLayout() {
        removeEmbeddedControllerIfNeeded()
        detachOverviewNavigationControllerFromSplit()

        if let rootViewController = overviewNavigationController.viewControllers.first {
            if let currentDetailFactory {
                overviewNavigationController.setViewControllers([rootViewController, currentDetailFactory()], animated: false)
            } else {
                overviewNavigationController.setViewControllers([rootViewController], animated: false)
            }
        }

        embed(overviewNavigationController)
    }

    private func applySplitLayout() {
        removeEmbeddedControllerIfNeeded()

        if overviewNavigationController.parent != nil {
            overviewNavigationController.willMove(toParent: nil)
            overviewNavigationController.view.removeFromSuperview()
            overviewNavigationController.removeFromParent()
        }

        if let rootViewController = overviewNavigationController.viewControllers.first {
            overviewNavigationController.setViewControllers([rootViewController], animated: false)
        }

        splitContainerViewController.setViewController(overviewNavigationController, for: .primary)

        let detailViewController = currentDetailFactory?() ?? emptyDetailFactory()
        detailNavigationController.setViewControllers([detailViewController], animated: false)

        embed(splitContainerViewController)
    }

    private func detachOverviewNavigationControllerFromSplit() {
        if splitContainerViewController.viewController(for: .primary) === overviewNavigationController {
            splitContainerViewController.setViewController(primaryPlaceholderViewController, for: .primary)
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

    private func removeEmbeddedControllerIfNeeded() {
        guard let embeddedController else { return }

        embeddedController.willMove(toParent: nil)
        embeddedController.view.removeFromSuperview()
        embeddedController.removeFromParent()

        self.embeddedController = nil
    }

    private func embed(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        viewController.didMove(toParent: self)
        embeddedController = viewController
    }
}

final class SplitDetailPlaceholderViewController: UIViewController {

    private let message: String

    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = message
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.readableContentGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.readableContentGuide.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.readableContentGuide.trailingAnchor)
        ])
    }
}
