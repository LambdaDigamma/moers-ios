import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class AdaptiveTabSplitResizabilityTests: XCTestCase {
    func testSidebarSelectionReplacesSecondaryColumnAndItsBackStack() async throws {
        let overview = UIViewController()
        let primary = UINavigationController(rootViewController: overview)
        let split = AdaptiveTabSplitViewController(overviewNavigationController: primary) { UIViewController() }
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        window.rootViewController = split
        split.traitOverrides.horizontalSizeClass = .regular
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(split.view)

        let first = UIViewController()
        split.setDetail({ first })
        await settle(split.view)
        let previousColumn = try XCTUnwrap(split.viewController(for: .secondary) as? UINavigationController)
        split.pushDetail({ UIViewController() }, from: first, animated: false)
        XCTAssertEqual(previousColumn.viewControllers.count, 2)

        let replacement = UIViewController()
        split.setDetail({ replacement })
        await settle(split.view)
        let currentColumn = try XCTUnwrap(split.viewController(for: .secondary) as? UINavigationController)
        XCTAssertFalse(currentColumn === previousColumn)
        XCTAssertNil(previousColumn.parent)
        XCTAssertEqual(currentColumn.viewControllers.count, 1)
        XCTAssertTrue(currentColumn.topViewController === replacement)
        XCTAssertNil(currentColumn.transitionCoordinator)
        XCTAssertTrue(split.selectedDetailViewController === replacement)
        XCTAssertEqual(primary.viewControllers.count, 1)
        XCTAssertTrue(primary.topViewController === overview)
    }

    func testColumnWidthsFollowNativeSplitSizingAfterWindowResize() async {
        let primary = UINavigationController(rootViewController: UIViewController())
        let split = AdaptiveTabSplitViewController(overviewNavigationController: primary) { UIViewController() }
        split.loadViewIfNeeded()
        let nativeSplit = UISplitViewController(style: .doubleColumn)
        nativeSplit.preferredDisplayMode = split.preferredDisplayMode
        nativeSplit.preferredSplitBehavior = split.preferredSplitBehavior
        nativeSplit.presentsWithGesture = split.presentsWithGesture
        nativeSplit.primaryBackgroundStyle = split.primaryBackgroundStyle
        nativeSplit.setViewController(UINavigationController(rootViewController: UIViewController()), for: .primary)
        nativeSplit.setViewController(UINavigationController(rootViewController: UIViewController()), for: .secondary)
        split.traitOverrides.horizontalSizeClass = .regular
        nativeSplit.traitOverrides.horizontalSizeClass = .regular
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 951, height: 669))
        defer { window.isHidden = true }

        for size in [CGSize(width: 951, height: 669), CGSize(width: 1_194, height: 834), CGSize(width: 669, height: 951)] {
            window.frame.size = size
            window.rootViewController = split
            window.isHidden = false
            await settle(split.view)
            let primaryWidth = split.primaryColumnWidth
            XCTAssertFalse(split.isCollapsed)
            window.rootViewController = nativeSplit
            await settle(nativeSplit.view)
            XCTAssertFalse(nativeSplit.isCollapsed)
            XCTAssertGreaterThan(nativeSplit.primaryColumnWidth, 0)
            XCTAssertEqual(primaryWidth, nativeSplit.primaryColumnWidth, accuracy: 0.5, "Window size: \(size)")
        }
    }

    func testResizeRetainsDetailStackAndScrollPosition() async throws {
        let overview = UIViewController()
        let primary = UINavigationController(rootViewController: overview)
        let split = AdaptiveTabSplitViewController(overviewNavigationController: primary) { UIViewController() }
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        window.rootViewController = split
        split.traitOverrides.horizontalSizeClass = .regular
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(split.view)
        XCTAssertFalse(split.isCollapsed)

        let detail = UIViewController()
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: 400, height: 3_000)
        detail.view = scrollView
        var factoryCalls = 0
        split.setDetail({ factoryCalls += 1; return detail }, animated: false)
        let descendant = UIViewController()
        split.activeNavigationController.pushViewController(descendant, animated: false)
        scrollView.contentOffset.y = 180

        for sizeClass in [UIUserInterfaceSizeClass.compact, .regular, .compact] {
            split.traitOverrides.horizontalSizeClass = sizeClass
            await settle(split.view)
            XCTAssertEqual(split.isCollapsed, sizeClass == .compact)
            let stack = split.activeNavigationController.viewControllers
            XCTAssertTrue(stack.contains { $0 === detail })
            XCTAssertTrue(stack.last === descendant)
            XCTAssertEqual(scrollView.contentOffset.y, 180, accuracy: 0.5)
            XCTAssertEqual(factoryCalls, 1)
        }
        XCTAssertTrue(split.activeNavigationController === primary)
        primary.popToRootViewController(animated: false)
        await settle(split.view)
        split.traitOverrides.horizontalSizeClass = .regular
        await settle(split.view)
        XCTAssertFalse(split.activeNavigationController.viewControllers.contains { $0 === detail || $0 === descendant })
        XCTAssertTrue(primary.viewControllers.first === overview)
    }

    func testSelectionBeforeAppearanceAndReplacementUseOneControllerEach() async {
        let primary = UINavigationController(rootViewController: UIViewController())
        let split = AdaptiveTabSplitViewController(overviewNavigationController: primary) { UIViewController() }
        let first = UIViewController()
        var factoryCalls = 0
        split.setDetail({ factoryCalls += 1; return first }, animated: false)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        split.traitOverrides.horizontalSizeClass = .compact
        window.rootViewController = split
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(split.view)
        XCTAssertTrue(primary.viewControllers.last === first)
        let replacement = UIViewController()
        split.setDetail({ factoryCalls += 1; return replacement }, animated: false)
        await settle(split.view)
        XCTAssertEqual(factoryCalls, 2)
        XCTAssertEqual(primary.viewControllers.count, 2)
        XCTAssertTrue(primary.viewControllers.last === replacement)
        XCTAssertNil(first.parent)
    }

    func testBothProgrammeCoordinatorsUseAdaptiveRootsAndKeepSearchNavigation() async {
        let programme = EventCoordinator()
        let saved = UserScheduleCoordinator()
        XCTAssertTrue(programme.rootViewController is AdaptiveTabSplitViewController)
        XCTAssertTrue(saved.rootViewController is AdaptiveTabSplitViewController)
        let search = UINavigationController(rootViewController: UIViewController())
        programme.currentModalNavigationController = search
        XCTAssertTrue(programme.activeNavigationController === search)
    }

    func testCollapseRecoversNestedDetailAfterSystemRestoresOverview() async {
        let overview = UIViewController()
        let primary = UINavigationController(rootViewController: overview)
        let split = AdaptiveTabSplitViewController(overviewNavigationController: primary) { UIViewController() }
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        split.traitOverrides.horizontalSizeClass = .regular
        window.rootViewController = split
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(split.view)
        let detail = UIViewController()
        let descendant = UIViewController()
        split.setDetail({ detail }, animated: false)
        split.activeNavigationController.pushViewController(descendant, animated: false)

        _ = split.splitViewController(split, topColumnForCollapsingToProposedTopColumn: .primary)
        // UIKit can display the overview again while it installs the collapsed columns.
        primary.setViewControllers([overview], animated: false)
        split.navigationController(primary, didShow: overview, animated: false)
        XCTAssertTrue(split.selectedDetailViewController === detail)
        split.splitViewControllerDidCollapse(split)
        XCTAssertTrue(primary.viewControllers.last === descendant)
        XCTAssertTrue(primary.viewControllers.contains { $0 === detail })

        split.splitViewControllerDidExpand(split)
        XCTAssertTrue(split.selectedDetailViewController === detail)
        XCTAssertTrue(split.activeNavigationController.topViewController === descendant)
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<8 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
