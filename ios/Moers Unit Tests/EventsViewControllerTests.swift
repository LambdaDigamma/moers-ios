import Core
import Events
import UIKit
import XCTest
@testable import Moers

@MainActor
final class EventsViewControllerTests: XCTestCase {
    private var animationsWereEnabled = true

    override func setUp() async throws {
        try await super.setUp()
        animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() async throws {
        UIView.setAnimationsEnabled(animationsWereEnabled)
        try await super.tearDown()
    }

    func testQuickFilterSelectionAndHeaderCountFollowTheResults() async throws {
        let now = Date()
        let events = [Event(id: 1, name: "Library", startDate: now), Event(id: 2, name: "Museum", startDate: now)]
        let controller = Moers.EventsViewController(eventService: StaticEventService(events: .success(events)))
        let window = install(controller)
        defer { window.isHidden = true }
        let collection = try XCTUnwrap(controller.view.subviews.compactMap { $0 as? UICollectionView }.first)
        await settle(collection)
        let chipPath = IndexPath(item: 0, section: 0)
        collection.delegate?.collectionView?(collection, didSelectItemAt: chipPath)
        await settle(collection)
        let chip = try XCTUnwrap(collection.cellForItem(at: chipPath))
        XCTAssertTrue(chip.accessibilityTraits.contains(.selected))
        let search = try XCTUnwrap(controller.navigationItem.searchController)
        search.searchBar.text = "Library"
        search.searchResultsUpdater?.updateSearchResults(for: search)
        try await Task.sleep(for: .milliseconds(200))
        await settle(collection)
        XCTAssertEqual(collection.numberOfItems(inSection: 1), 1)
        let header = try XCTUnwrap(collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 1)))
        XCTAssertTrue(labels(in: header).contains("1"))
    }

    func testEventsWithNoDisplayableDateShowAnEmptyState() async throws {
        let past = Date().addingTimeInterval(-172_800)
        let events = [Event(id: 1, name: "Undated"), Event(id: 2, name: "Ended", startDate: past, endDate: past)]
        let controller = Moers.EventsViewController(eventService: StaticEventService(events: .success(events)))
        let window = install(controller)
        defer { window.isHidden = true }
        await settle(controller.view)
        XCTAssertTrue(labels(in: controller.view).contains("No events found"))
    }

    func testFailureOffersRetryAndPullToRefresh() async throws {
        let controller = Moers.EventsViewController(eventService: StaticEventService(events: .failure(URLError(.notConnectedToInternet))))
        let window = install(controller)
        defer { window.isHidden = true }
        await settle(controller.view)
        XCTAssertTrue(labels(in: controller.view).contains("Events could not be loaded"))
        let collection = try XCTUnwrap(controller.view.subviews.compactMap { $0 as? UICollectionView }.first)
        XCTAssertNotNil(collection.refreshControl)
        XCTAssertTrue(buttons(in: controller.view).contains { $0.accessibilityIdentifier == "events.retry" && !$0.isHidden })
    }

    func testPartialFailureKeepsRowsAndRetryReplacesTheWarning() async throws {
        let service = RecoveringEventService(events: [Event(id: 1, name: "Library", startDate: Date())])
        let controller = Moers.EventsViewController(eventService: service)
        let window = install(controller)
        defer { window.isHidden = true }
        await settle(controller.view)
        XCTAssertTrue(labels(in: controller.view).contains("Library"))
        XCTAssertTrue(labels(in: controller.view).contains("Events could not be loaded"))
        let retry = try XCTUnwrap(buttons(in: controller.view).first { $0.accessibilityIdentifier == "events.retry" && !$0.isHidden })
        retry.sendActions(for: .touchUpInside)
        await settle(controller.view)
        XCTAssertEqual(service.requestCount, 2)
        XCTAssertTrue(labels(in: controller.view).contains("Library"))
        XCTAssertFalse(labels(in: controller.view).contains("Events could not be loaded"))
        let collection = try collectionView(in: controller)
        XCTAssertFalse(collection.refreshControl?.isRefreshing ?? true)
    }

    func testCalendarDayChangeReloadsAndMovesTomorrowToToday() async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        var clock = Date(timeIntervalSince1970: 1_791_240_000)
        clock = calendar.startOfDay(for: clock)
        let nextDay = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: clock))
        let service = RecoveringEventService(events: [Event(id: 1, name: "Library", startDate: nextDay.addingTimeInterval(36_000))], failsFirstRequest: false)
        let controller = Moers.EventsViewController(eventService: service, calendar: calendar, now: { clock })
        let window = install(controller)
        defer { window.isHidden = true }
        await settle(controller.view)
        let collection = try collectionView(in: controller)
        XCTAssertTrue(headerLabels(in: collection).contains("Tomorrow"))
        XCTAssertFalse(headerLabels(in: collection).contains("Today"))
        let requestCount = service.requestCount
        clock = nextDay
        NotificationCenter.default.post(name: .NSCalendarDayChanged, object: nil)
        await settle(controller.view)
        XCTAssertEqual(service.requestCount, requestCount + 1)
        XCTAssertTrue(headerLabels(in: collection).contains("Today"))
        XCTAssertFalse(headerLabels(in: collection).contains("Tomorrow"))
    }

    func testRowSelectedDuringSearchDismissalWaitsForTheTransition() async throws {
        let controller = Moers.EventsViewController(eventService: StaticEventService(events: .success([Event(id: 1, name: "Library", startDate: Date())])))
        let window = install(controller)
        defer { window.isHidden = true }
        let collection = try collectionView(in: controller)
        await settle(collection)
        let navigation = try XCTUnwrap(controller.navigationController)
        let search = try XCTUnwrap(controller.navigationItem.searchController)
        // UIKit can clear isActive before its dismissal transition ends.
        controller.willDismissSearchController(search)
        XCTAssertFalse(search.isActive)
        collection.delegate?.collectionView?(collection, didSelectItemAt: IndexPath(item: 0, section: 1))
        XCTAssertTrue(navigation.topViewController === controller)
        controller.didDismissSearchController(search)
        await settle(navigation.view)
        XCTAssertTrue(navigation.topViewController is EventDetailViewController)
        XCTAssertEqual(navigation.viewControllers.count, 2)
    }

    private func collectionView(in controller: Moers.EventsViewController) throws -> UICollectionView {
        try XCTUnwrap(controller.view.subviews.compactMap { $0 as? UICollectionView }.first)
    }

    private func headerLabels(in collection: UICollectionView) -> [String] {
        collection.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).flatMap(labels(in:))
    }

    private func install(_ controller: Moers.EventsViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 430, height: 900))
        window.rootViewController = UINavigationController(rootViewController: controller)
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        controller.loadViewIfNeeded()
        return window
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<12 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private func labels(in view: UIView) -> [String] {
        guard !view.isHidden else { return [] }
        return ([view as? UILabel].compactMap { $0?.text }) + view.subviews.flatMap(labels(in:))
    }

    private func buttons(in view: UIView) -> [UIButton] {
        ([view as? UIButton].compactMap { $0 }) + view.subviews.flatMap(buttons(in:))
    }
}
