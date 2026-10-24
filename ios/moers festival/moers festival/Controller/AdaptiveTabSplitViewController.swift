import UIKit

final class AdaptiveTabSplitViewController: UISplitViewController, UINavigationControllerDelegate, UISplitViewControllerDelegate {
    private let overviewNavigationController: UINavigationController
    private var detailNavigationController = UINavigationController()
    private let emptyDetailFactory: () -> UIViewController
    private var currentDetailViewController: UIViewController?
    private var detailIsInCompactStack = false
    private var transitioningDetailStack: [UIViewController]?
    private var isTransferringDetail = false

    var onDetailPresentationChange: (() -> Void)?
    var onColumnsWillChange: (() -> Void)?
    var selectedDetailViewController: UIViewController? { currentDetailViewController }
    // UIKit can notify collapse before its isCollapsed property changes.
    var showsDetailColumn: Bool { !detailIsInCompactStack }

    var activeNavigationController: UINavigationController {
        isCollapsed ? overviewNavigationController : detailNavigationController
    }

    init(
        overviewNavigationController: UINavigationController,
        emptyDetailFactory: @escaping () -> UIViewController
    ) {
        self.overviewNavigationController = overviewNavigationController
        self.emptyDetailFactory = emptyDetailFactory
        super.init(style: .doubleColumn)
        tabBarItem = overviewNavigationController.tabBarItem
        title = overviewNavigationController.title
        overviewNavigationController.delegate = self
        delegate = self
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
        primaryBackgroundStyle = .none
        overviewNavigationController.view.backgroundColor = .systemBackground
        detailNavigationController.navigationBar.prefersLargeTitles = true
        detailNavigationController.setViewControllers(
            [currentDetailViewController ?? emptyDetailFactory()], animated: false
        )
        setViewController(overviewNavigationController, for: .primary)
        setViewController(detailNavigationController, for: .secondary)
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if transitioningDetailStack != nil {
            return
        } else if isCollapsed {
            moveDetailToCompactStack()
        } else {
            moveDetailToRegularColumn()
        }
        onDetailPresentationChange?()
    }

    func setDetail(_ detailFactory: () -> UIViewController, animated: Bool = true) {
        defer { onDetailPresentationChange?() }
        let detail = detailFactory()
        currentDetailViewController = detail
        if transitioningDetailStack != nil {
            transitioningDetailStack = [detail]
            return
        }
        guard isViewLoaded else { return }
        isTransferringDetail = true
        defer { isTransferringDetail = false }
        if isCollapsed {
            guard let overview = overviewNavigationController.viewControllers.first else { return }
            detailIsInCompactStack = true
            detailNavigationController.setViewControllers([emptyDetailFactory()], animated: false)
            overviewNavigationController.setViewControllers([overview, detail], animated: animated)
        } else {
            detailNavigationController = UINavigationController(rootViewController: detail)
            detailNavigationController.navigationBar.prefersLargeTitles = true
            setViewController(detailNavigationController, for: .secondary)
            show(.secondary)
        }
    }

    func showEmptyDetail(animated: Bool = false) {
        defer { onDetailPresentationChange?() }
        currentDetailViewController = nil
        if transitioningDetailStack != nil {
            transitioningDetailStack = []
            return
        }
        guard isViewLoaded else { return }
        detailNavigationController.setViewControllers([emptyDetailFactory()], animated: false)
        if isCollapsed {
            overviewNavigationController.popToRootViewController(animated: animated)
        }
    }

    func pushDetail(_ detailFactory: () -> UIViewController, from source: UIViewController, animated: Bool = true) {
        if var stack = transitioningDetailStack {
            guard stack.contains(where: { $0 === source }) else { return }
            stack.append(detailFactory())
            transitioningDetailStack = stack
            return
        }
        guard let navigationController = source.navigationController,
              navigationController === overviewNavigationController || navigationController === detailNavigationController,
              navigationController.viewControllers.contains(where: { $0 === source }) else { return }
        navigationController.pushViewController(detailFactory(), animated: animated)
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard navigationController === overviewNavigationController,
              transitioningDetailStack == nil,
              !isTransferringDetail,
              detailIsInCompactStack,
              navigationController.viewControllers.count == 1,
              viewController === navigationController.viewControllers.first else { return }
        currentDetailViewController = nil
        onDetailPresentationChange?()
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        retainDetailForColumnChange()
        return .primary
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode
    ) -> UISplitViewController.DisplayMode {
        retainDetailForColumnChange()
        return proposedDisplayMode
    }

    func splitViewControllerDidCollapse(_ splitViewController: UISplitViewController) {
        moveDetailToCompactStack()
        onDetailPresentationChange?()
    }

    func splitViewControllerDidExpand(_ splitViewController: UISplitViewController) {
        moveDetailToRegularColumn()
        onDetailPresentationChange?()
    }

    private func moveDetailToCompactStack() {
        guard !detailIsInCompactStack || transitioningDetailStack != nil,
              let overview = overviewNavigationController.viewControllers.first else { return }
        let detailStack = transitioningDetailStack ?? selectedStack(in: detailNavigationController)
        isTransferringDetail = true
        // Remove the stack from its old parent before installing the same instances.
        detailNavigationController.setViewControllers([emptyDetailFactory()], animated: false)
        overviewNavigationController.setViewControllers([overview] + detailStack, animated: false)
        currentDetailViewController = detailStack.first
        detailIsInCompactStack = true
        transitioningDetailStack = nil
        isTransferringDetail = false
    }

    private func moveDetailToRegularColumn() {
        guard detailIsInCompactStack || transitioningDetailStack != nil,
              let overview = overviewNavigationController.viewControllers.first else { return }
        let detailStack = transitioningDetailStack ?? selectedStack(in: overviewNavigationController)
        isTransferringDetail = true
        overviewNavigationController.setViewControllers([overview], animated: false)
        currentDetailViewController = detailStack.first
        detailNavigationController.setViewControllers(
            detailStack.isEmpty ? [emptyDetailFactory()] : detailStack, animated: false
        )
        detailIsInCompactStack = false
        transitioningDetailStack = nil
        isTransferringDetail = false
    }

    private func retainDetailForColumnChange() {
        guard transitioningDetailStack == nil else { return }
        onColumnsWillChange?()
        let source = detailIsInCompactStack ? overviewNavigationController : detailNavigationController
        transitioningDetailStack = selectedStack(in: source)
    }

    private func selectedStack(in navigationController: UINavigationController) -> [UIViewController] {
        guard let currentDetailViewController,
              let index = navigationController.viewControllers.firstIndex(where: { $0 === currentDetailViewController })
        else { return [] }
        return Array(navigationController.viewControllers[index...])
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
