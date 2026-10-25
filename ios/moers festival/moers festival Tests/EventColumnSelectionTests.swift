import Events
import FactoryKit
import GRDB
import SwiftUI
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class EventColumnSelectionTests: XCTestCase {
    private var savedDefaults: [String: Any] = [:]
    private let defaultsKeys = ["timetableFilter", "favoritesFilter", "currentEventDisplayMode"]
    private var favorites: FavoriteEventsStore!

    override func setUp() async throws {
        try await super.setUp()
        for key in defaultsKeys {
            savedDefaults[key] = UserDefaults.standard.object(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.set(DailyEventsDisplayMode.compact.rawValue, forKey: "currentEventDisplayMode")
        let queue = try DatabaseQueue()
        let database = try AppDatabase(queue)
        let store = EventStore(writer: database.dbWriter, reader: database.reader)
        let start = Calendar.current.startOfDay(for: .now).addingTimeInterval(12 * 60 * 60)
        let events = [
            Event(id: 1, name: "First event", startDate: start),
            Event(id: 2, name: "Second event", startDate: start.addingTimeInterval(60 * 60))
        ]
        try await store.deleteAllAndInsert(events.map { $0.toRecord() })
        let repository = EventRepository(
            store: store, service: StaticEventService(events: .success(events)), pageStore: nil
        )
        favorites = FavoriteEventsStore(writer: queue, reader: queue)
        Container.shared.eventRepository.register { repository }
        Container.shared.favoriteEventsStore.register { [favorites = self.favorites] in favorites }
        for event in events {
            try await favorites.createFavoriteEvent(eventID: event.id)
        }
    }

    override func tearDown() async throws {
        for key in defaultsKeys {
            UserDefaults.standard.set(savedDefaults[key], forKey: key)
        }
        savedDefaults = [:]
        Container.shared.eventRepository.reset()
        Container.shared.favoriteEventsStore.reset()
        favorites = nil
        try await super.tearDown()
    }

    func testSelectionFollowsEventIdentityAfterRefreshFilteringAndReuse() async {
        let page = TimetableDayPageCell(frame: CGRect(x: 0, y: 0, width: 340, height: 600))
        let window = mount(page)
        defer { window.isHidden = true }
        page.selectedEventID = 2
        configure(page, ids: [1, 2])
        await settle(window)
        XCTAssertEqual(page.listView.indexPathsForSelectedItems, [IndexPath(item: 1, section: 0)])

        // New row models have new UUIDs. The event ID must still identify the selected event.
        configure(page, ids: [2, 1])
        await settle(window)
        XCTAssertEqual(page.listView.indexPathsForSelectedItems, [IndexPath(item: 0, section: 0)])
        configure(page, ids: [1])
        await settle(window)
        XCTAssertTrue(page.listView.indexPathsForSelectedItems?.isEmpty != false)
        configure(page, ids: [2])
        await settle(window)
        XCTAssertEqual(page.listView.indexPathsForSelectedItems, [IndexPath(item: 0, section: 0)])
        page.selectedEventID = nil
        XCTAssertTrue(page.listView.indexPathsForSelectedItems?.isEmpty != false)
    }

    func testProgrammaticSelectionDoesNotNavigateOrScroll() async {
        let page = TimetableDayPageCell(frame: CGRect(x: 0, y: 0, width: 340, height: 600))
        let window = mount(page)
        defer { window.isHidden = true }
        var navigationRequests = 0
        page.configure(
            events: (1...20).map { EventListItemViewModel(eventID: Event.ID($0), title: "Event \($0)") },
            isFilterActive: false, displayMode: .compact,
            onSelectEvent: { _ in navigationRequests += 1 }
        )
        await settle(window)
        let offset = page.listView.contentOffset
        page.selectedEventID = 20
        XCTAssertEqual(page.listView.indexPathsForSelectedItems, [IndexPath(item: 19, section: 0)])
        XCTAssertEqual(page.listView.contentOffset, offset)
        XCTAssertEqual(navigationRequests, 0)
    }

    func testTapKeepsImageRowSelectedOnlyWhileItsDetailIsInTheColumn() async throws {
        let page = TimetableDayPageCell(frame: CGRect(x: 0, y: 0, width: 340, height: 600))
        let window = mount(page)
        defer { window.isHidden = true }
        page.configure(
            events: [EventListItemViewModel(eventID: 1, title: "Image event")],
            isFilterActive: false, displayMode: .images,
            onSelectEvent: { [weak page] in page?.selectedEventID = $0 }
        )
        await settle(window)
        let indexPath = IndexPath(item: 0, section: 0)
        page.listView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        page.collectionView(page.listView, didSelectItemAt: indexPath)
        XCTAssertEqual(page.listView.indexPathsForSelectedItems, [indexPath])
        let cell = try XCTUnwrap(page.listView.cellForItem(at: indexPath))
        XCTAssertTrue(cell.isSelected)
        XCTAssertNotNil(cell.backgroundConfiguration)

        page.selectedEventID = nil
        configure(page, ids: [1])
        await settle(window)
        page.listView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        page.collectionView(page.listView, didSelectItemAt: indexPath)
        XCTAssertTrue(page.listView.indexPathsForSelectedItems?.isEmpty != false)
    }

    func testProgrammeSelectionTracksDetailReplacementResizeAndCompactBack() async throws {
        let coordinator = EventCoordinator()
        let split = try XCTUnwrap(coordinator.rootViewController as? AdaptiveTabSplitViewController)
        let overview = try XCTUnwrap(coordinator.navigationController.viewControllers.first as? TimetableViewController)
        let window = show(split)
        defer { window.isHidden = true }
        let page = try await loadedPage(in: overview.view)

        coordinator.showDetail(for: 1, animated: false)
        await settle(window)
        XCTAssertEqual(overview.selectedEventID, 1)
        try assertSelectedEvent(1, in: page)
        coordinator.showDetail(for: 2, animated: false)
        await settle(window)
        XCTAssertEqual(overview.selectedEventID, 2)
        try assertSelectedEvent(2, in: page)

        split.traitOverrides.horizontalSizeClass = .compact
        await settle(window)
        XCTAssertNil(overview.selectedEventID)
        XCTAssertTrue(page.listView.indexPathsForSelectedItems?.isEmpty != false)
        split.traitOverrides.horizontalSizeClass = .regular
        await settle(window)
        XCTAssertEqual(overview.selectedEventID, 2)
        let restoredPage = try await loadedPage(in: overview.view)
        try assertSelectedEvent(2, in: restoredPage)

        split.traitOverrides.horizontalSizeClass = .compact
        await settle(window)
        coordinator.navigationController.popToRootViewController(animated: false)
        await settle(window)
        split.traitOverrides.horizontalSizeClass = .regular
        await settle(window)
        XCTAssertNil(overview.selectedEventID)
        coordinator.showDetail(for: 1, animated: false)
        coordinator.showOverview()
        XCTAssertNil(overview.selectedEventID)
    }

    func testProgrammePreviewListUsesNativeSelectionForTheActiveEvent() async throws {
        let queue = try DatabaseQueue()
        let database = try AppDatabase(queue)
        let store = EventStore(writer: database.dbWriter, reader: database.reader)
        let events = [
            Event(id: 1, name: "First preview", extras: EventExtras(scheduleDisplay: .hidden)),
            Event(id: 2, name: "Second preview", extras: EventExtras(scheduleDisplay: .hidden))
        ]
        try await store.deleteAllAndInsert(events.map { $0.toRecord() })
        let repository = EventRepository(
            store: store, service: StaticEventService(events: .success(events)), pageStore: nil
        )
        Container.shared.eventRepository.register { repository }
        let coordinator = EventCoordinator()
        let overview = try XCTUnwrap(coordinator.navigationController.viewControllers.first as? TimetableViewController)
        let window = show(coordinator.rootViewController)
        defer { window.isHidden = true }
        var list: UICollectionView?
        for _ in 0..<60 {
            await settle(window)
            if let hosting = overview.children.compactMap({ $0 as? UIHostingController<AnyView> }).first {
                list = descendants(of: hosting.view).compactMap { $0 as? UICollectionView }.first { collection in
                    (0..<collection.numberOfSections).reduce(0) { count, section in
                        count + collection.numberOfItems(inSection: section)
                    } == 2
                }
            }
            if list != nil { break }
        }
        let previewList = try XCTUnwrap(list)
        coordinator.showDetail(for: 2, animated: false)
        await settle(window)
        XCTAssertEqual(previewList.indexPathsForSelectedItems?.count, 1)
        coordinator.showOverview()
        await settle(window)
        XCTAssertTrue(previewList.indexPathsForSelectedItems?.isEmpty != false)
    }

    func testFavoritesSelectionReturnsAfterFilteringAndFavoriteRemoval() async throws {
        let coordinator = UserScheduleCoordinator()
        let split = try XCTUnwrap(coordinator.rootViewController as? AdaptiveTabSplitViewController)
        let overview = try XCTUnwrap(coordinator.navigationController.viewControllers.first as? UserScheduleViewController)
        let window = show(split)
        defer { window.isHidden = true }
        _ = try await loadedPage(in: overview.view)
        coordinator.showDetail(for: 2, animated: false)
        await settle(window)
        let page = try await loadedPage(in: overview.view)
        try assertSelectedEvent(2, in: page)

        overview.filter = EventFilter(venueIDs: [999])
        await settle(window)
        XCTAssertEqual(overview.selectedEventID, 2)
        overview.filter = .empty
        await settle(window)
        let unfilteredPage = try await loadedPage(in: overview.view)
        try assertSelectedEvent(2, in: unfilteredPage)
        try await favorites.deleteFavoriteEvent(eventID: 2)
        await settle(window)
        let remainingPage = try await loadedPage(in: overview.view, count: 1)
        XCTAssertTrue(remainingPage.listView.indexPathsForSelectedItems?.isEmpty != false)
        try await favorites.createFavoriteEvent(eventID: 2)
        await settle(window)
        let restoredPage = try await loadedPage(in: overview.view)
        try assertSelectedEvent(2, in: restoredPage)
        coordinator.showOverview()
        XCTAssertNil(overview.selectedEventID)
        XCTAssertTrue(restoredPage.listView.indexPathsForSelectedItems?.isEmpty != false)
    }

    private func configure(_ page: TimetableDayPageCell, ids: [Event.ID]) {
        page.configure(
            events: ids.map { EventListItemViewModel(eventID: $0, title: "Event \($0)") },
            isFilterActive: false, displayMode: .compact, onSelectEvent: { _ in }
        )
    }

    private func mount(_ page: TimetableDayPageCell) -> UIWindow {
        let controller = UIViewController()
        controller.view.addSubview(page)
        return show(controller)
    }

    private func show(_ controller: UIViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        controller.traitOverrides.horizontalSizeClass = .regular
        window.rootViewController = controller
        window.isHidden = false
        return window
    }

    private func loadedPage(in view: UIView, count: Int = 2) async throws -> TimetableDayPageCell {
        for _ in 0..<60 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            if let page = descendants(of: view).compactMap({ $0 as? TimetableDayPageCell }).first(where: {
                $0.listView.numberOfSections > 0 && $0.listView.numberOfItems(inSection: 0) == count
            }) {
                return page
            }
            try? await Task.sleep(for: .milliseconds(20))
        }
        return try XCTUnwrap(nil as TimetableDayPageCell?, "The event page did not load its fixture events.")
    }

    private func assertSelectedEvent(_ eventID: Event.ID, in page: TimetableDayPageCell) throws {
        let selection = page.listView.indexPathsForSelectedItems ?? []
        XCTAssertEqual(selection.count, 1)
        let indexPath = try XCTUnwrap(selection.first)
        let cell = try XCTUnwrap(page.listView.cellForItem(at: indexPath))
        XCTAssertTrue(cell.isSelected)
        XCTAssertEqual(cell.accessibilityIdentifier, "Event-Row-\(eventID)")
    }

    private func descendants(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<12 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
