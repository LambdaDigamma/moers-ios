import Core
import UIKit
import XCTest
@testable import Moers

@MainActor
final class TabNavigationResizabilityTests: XCTestCase {
    private var previousFirstLaunchValue: Any?

    override func setUp() async throws {
        try await super.setUp()
        previousFirstLaunchValue = UserDefaults.appGroup.object(forKey: Constants.firstLaunch)
    }

    override func tearDown() async throws {
        if let previousFirstLaunchValue {
            UserDefaults.appGroup.set(previousFirstLaunchValue, forKey: Constants.firstLaunch)
        } else {
            UserDefaults.appGroup.removeObject(forKey: Constants.firstLaunch)
        }
        try await super.tearDown()
    }

    func testResizeRetainsSelectedSectionDetailAndNavigationStacks() async throws {
        let coordinator = ApplicationCoordinator()
        let tabs = try XCTUnwrap(coordinator.rootViewController() as? AppTabBarController)
        let navigationControllers = sectionNavigationControllers(in: coordinator)
        installPlaceholderOverviews(in: navigationControllers)
        tabs.loadViewIfNeeded()
        let sectionRoots = try XCTUnwrap(tabs.viewControllers)
        let other = coordinator.currentOther.navigationController
        let detail = UIViewController()
        tabs.selectedIndex = TabIndices.other.rawValue
        other.pushViewController(detail, animated: false)

        // A resize must not replay a different activity over the user's current screen.
        let previousActivity = UserActivity.current
        UserActivity.current = NSUserActivity(activityType: UserActivities.IDs.dashboard)
        defer { UserActivity.current = previousActivity }

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = tabs
        // Keep the window hidden so layout checks cannot start onboarding or refresh preferences.
        window.addSubview(tabs.view)

        for (width, sizeClass) in [
            (CGFloat(375), UIUserInterfaceSizeClass.compact),
            (CGFloat(1_024), UIUserInterfaceSizeClass.regular),
            (CGFloat(375), UIUserInterfaceSizeClass.compact)
        ] {
            window.frame.size.width = width
            tabs.view.frame = window.bounds
            tabs.traitOverrides.horizontalSizeClass = sizeClass
            await settle(tabs.view)

            XCTAssertEqual(tabs.traitCollection.horizontalSizeClass, sizeClass)
            XCTAssertEqual(tabs.view.bounds.width, width, accuracy: 0.5)
            XCTAssertEqual(other.view.bounds.width, width, accuracy: 0.5)
            XCTAssertEqual(tabs.selectedIndex, TabIndices.other.rawValue)
            XCTAssertTrue(tabs.selectedViewController === other)
            XCTAssertTrue(other.topViewController === detail)
            XCTAssertEqual(other.viewControllers.count, 2)
            XCTAssertEqual(tabs.viewControllers?.map(ObjectIdentifier.init), sectionRoots.map(ObjectIdentifier.init))
            XCTAssertEqual(
                sectionNavigationControllers(in: coordinator).map(ObjectIdentifier.init),
                navigationControllers.map(ObjectIdentifier.init)
            )
        }
    }

    func testRepeatedRootRetrievalRetainsSelectionAndDetail() async throws {
        let coordinator = ApplicationCoordinator()
        let tabs = try XCTUnwrap(coordinator.rootViewController() as? AppTabBarController)
        installPlaceholderOverviews(in: sectionNavigationControllers(in: coordinator))
        tabs.loadViewIfNeeded()
        coordinator.openNewsOverview()
        let news = coordinator.currentNews.navigationController
        let detail = UIViewController()
        news.pushViewController(detail, animated: false)

        for _ in 0..<3 {
            XCTAssertTrue(coordinator.rootViewController() === tabs)
            XCTAssertEqual(tabs.selectedIndex, TabIndices.news.rawValue)
            XCTAssertTrue(tabs.selectedViewController === news)
            XCTAssertTrue(coordinator.currentNews.navigationController === news)
            XCTAssertTrue(news.topViewController === detail)
            XCTAssertEqual(news.viewControllers.count, 2)
        }
    }

    func testUserActivityRoutesUseExistingSectionStacksAtEitherWidth() async throws {
        let coordinator = ApplicationCoordinator()
        let tabs = try XCTUnwrap(coordinator.rootViewController() as? AppTabBarController)
        let navigationControllers = sectionNavigationControllers(in: coordinator)
        installPlaceholderOverviews(in: navigationControllers)
        tabs.loadViewIfNeeded()
        let other = coordinator.currentOther.navigationController
        let otherOverview = other.viewControllers.first
        let map = coordinator.currentMap.navigationController

        for sizeClass in [UIUserInterfaceSizeClass.regular, .compact] {
            tabs.traitOverrides.horizontalSizeClass = sizeClass
            await settle(tabs.view)
            coordinator.handle(userActivity: NSUserActivity(activityType: UserActivities.IDs.settings))

            XCTAssertEqual(tabs.selectedIndex, TabIndices.other.rawValue)
            XCTAssertTrue(tabs.selectedViewController === other)
            XCTAssertTrue(coordinator.currentOther.navigationController === other)
            XCTAssertTrue(other.viewControllers.first === otherOverview)
            XCTAssertEqual(other.viewControllers.count, 2)

            coordinator.handle(userActivity: NSUserActivity(activityType: UserActivities.IDs.map))

            XCTAssertEqual(tabs.selectedIndex, TabIndices.maps.rawValue)
            XCTAssertTrue(tabs.selectedViewController === map)
            XCTAssertTrue(coordinator.currentMap.navigationController === map)
            XCTAssertEqual(map.viewControllers.count, 1)
            XCTAssertEqual(other.viewControllers.count, 2)
        }
    }

    private func sectionNavigationControllers(in coordinator: ApplicationCoordinator) -> [UINavigationController] {
        [
            coordinator.currentDashboard.navigationController,
            coordinator.currentNews.navigationController,
            coordinator.currentMap.navigationController,
            coordinator.currentEvents.navigationController,
            coordinator.currentOther.navigationController
        ]
    }

    private func installPlaceholderOverviews(in navigationControllers: [UINavigationController]) {
        for navigationController in navigationControllers {
            navigationController.setViewControllers([UIViewController()], animated: false)
        }
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<4 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
