import FactoryKit
import GRDB
import Events
import SwiftUI
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class UserScheduleDayNavigationTests: XCTestCase {
    private var previousFilter: Any?

    override func setUp() async throws {
        try await super.setUp()
        previousFilter = UserDefaults.standard.object(forKey: "favoritesFilter")
        UserDefaults.standard.removeObject(forKey: "favoritesFilter")
    }

    override func tearDown() async throws {
        UserDefaults.standard.set(previousFilter, forKey: "favoritesFilter")
        Container.shared.favoriteEventsStore.reset()
        try await super.tearDown()
    }

    func testGroupingKeepsThreeAMBoundaryAndUnscheduledFavorites() async {
        XCTAssertEqual(UserScheduleDay(startDate: date(day: 22, hour: 2)), .scheduled(date(day: 21)))
        XCTAssertEqual(UserScheduleDay(startDate: date(day: 22, hour: 4)), .scheduled(date(day: 22)))
        XCTAssertEqual(UserScheduleDay(startDate: nil), .unscheduled)
    }

    func testScheduledAndUnscheduledDaysRemainSelectable() async throws {
        let (controller, _) = try await makeController(events: [
            event(id: 1, startDate: date(day: 21, hour: 12)),
            event(id: 2, startDate: date(day: 22, hour: 12)),
            event(id: 3, startDate: nil)
        ])
        await waitUntil { controller.days.count == 3 }
        XCTAssertEqual(controller.days, [.scheduled(date(day: 21)), .scheduled(date(day: 22)), .unscheduled])
        controller.selectDay(.unscheduled)
        XCTAssertEqual(controller.selectedDay, .unscheduled)
        controller.selectDay(.scheduled(date(day: 22)))
        XCTAssertEqual(controller.selectedDay, .scheduled(date(day: 22)))
    }

    func testRemovingFavoritesPreservesSelectionOrSelectsAnAvailableDay() async throws {
        let (controller, favorites) = try await makeController(events: [
            event(id: 1, startDate: date(day: 21, hour: 12)),
            event(id: 2, startDate: date(day: 22, hour: 12)),
            event(id: 3, startDate: nil)
        ])
        await waitUntil { controller.days.count == 3 }
        controller.selectDay(.scheduled(date(day: 22)))
        try await favorites.deleteFavoriteEvent(eventID: 1)
        await waitUntil { controller.days.count == 2 }
        XCTAssertEqual(controller.selectedDay, .scheduled(date(day: 22)))
        try await favorites.deleteFavoriteEvent(eventID: 2)
        await waitUntil { controller.days == [.unscheduled] }
        XCTAssertEqual(controller.selectedDay, .unscheduled)
    }

    func testEmptyFilteredResultsKeepClearFilterAvailable() async throws {
        let (controller, _) = try await makeController(events: [event(id: 1, startDate: date(day: 21, hour: 12))])
        await waitUntil { !controller.days.isEmpty }
        controller.filter = EventFilter(venueIDs: [999])
        await waitUntil { controller.days.isEmpty }
        XCTAssertTrue(controller.days.isEmpty)
        XCTAssertNil(controller.selectedDay)
        XCTAssertNotNil(controller.collectionView.backgroundView)
        XCTAssertNotNil(controller.navigationItem.timetableBottomPalette)
        controller.filter = .empty
        await waitUntil { !controller.days.isEmpty }
        XCTAssertEqual(controller.days, [.scheduled(date(day: 21))])
    }

    func testObservationDoesNotRetainController() async throws {
        var controller: UserScheduleViewController? = try await makeController(events: []).0
        weak let released = controller
        controller = nil
        for _ in 0..<10 where released != nil { await Task.yield() }
        XCTAssertNil(released)
    }

    func testFilterSheetEditsUpdateFavoritesPersistAndSurviveReopening() async throws {
        let (controller, _) = try await makeController(events: [event(id: 1, startDate: date(day: 21, hour: 12))])
        await waitUntil { !controller.days.isEmpty }
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.isHidden = false
        defer { window.isHidden = true }

        controller.showFilter()
        let sheet = try XCTUnwrap(controller.presentedViewController as? UIHostingController<EventFilterSheetWrapper>)
        await waitUntil { !sheet.isBeingPresented }
        let selectedFilter = EventFilter(venueIDs: [999])
        sheet.rootView.model.value = selectedFilter
        await waitUntil { controller.days.isEmpty }

        XCTAssertEqual(controller.filter, selectedFilter)
        XCTAssertTrue(controller.days.isEmpty)
        XCTAssertNotNil(controller.collectionView.backgroundView)
        let persisted = try XCTUnwrap(UserDefaults.standard.data(forKey: "favoritesFilter"))
        XCTAssertEqual(try JSONDecoder().decode(EventFilter.self, from: persisted), selectedFilter)

        controller.dismiss(animated: false)
        controller.showFilter()
        let reopened = try XCTUnwrap(controller.presentedViewController as? UIHostingController<EventFilterSheetWrapper>)
        await waitUntil { !reopened.isBeingPresented }
        XCTAssertEqual(reopened.rootView.model.value, selectedFilter)
        reopened.rootView.model.value = .empty
        await waitUntil { !controller.days.isEmpty }
        XCTAssertEqual(controller.filter, .empty)
        XCTAssertEqual(controller.days, [.scheduled(date(day: 21))])
        controller.dismiss(animated: false)
    }

    func testFilterModelDoesNotRetainControllerAfterSheetDismissal() async throws {
        var controller: UserScheduleViewController? = try await makeController(events: []).0
        weak let released = controller
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.isHidden = false
        defer { window.isHidden = true }

        controller?.showFilter()
        var sheet: UIHostingController<EventFilterSheetWrapper>? = try XCTUnwrap(
            controller?.presentedViewController as? UIHostingController<EventFilterSheetWrapper>
        )
        await waitUntil { sheet?.isBeingPresented == false }
        let model = try XCTUnwrap(sheet?.rootView.model)
        controller?.dismiss(animated: false)
        sheet = nil
        window.rootViewController = nil
        controller = nil
        await waitUntil { released == nil }

        XCTAssertNil(released)
        model.value = EventFilter(venueIDs: [999])
        XCTAssertNil(released)
    }

    func testResizeKeepsSelectedPageAligned() async throws {
        let (controller, _) = try await makeController(events: [
            event(id: 1, startDate: date(day: 21, hour: 12)),
            event(id: 2, startDate: date(day: 22, hour: 12))
        ])
        await waitUntil { controller.days.count == 2 }
        let container = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        window.rootViewController = container
        container.addChild(controller)
        container.view.addSubview(controller.view)
        controller.didMove(toParent: container)
        window.isHidden = false
        defer { window.isHidden = true }
        controller.view.frame = CGRect(x: 0, y: 0, width: 340, height: 700)
        controller.view.layoutIfNeeded()
        controller.selectDay(.scheduled(date(day: 22)))
        await waitUntil { abs(controller.collectionView.contentOffset.x - controller.collectionView.bounds.width) < 1 }

        for width in [CGFloat(360), 280, 420] {
            controller.view.frame.size.width = width
            controller.view.setNeedsLayout()
            controller.view.layoutIfNeeded()
            for _ in 0..<5 { await Task.yield() }
            XCTAssertEqual(controller.collectionView.contentOffset.x, controller.collectionView.bounds.width, accuracy: 1)
            XCTAssertEqual(controller.selectedDay, .scheduled(date(day: 22)))
        }
    }

    private func makeController(events: [Event]) async throws -> (UserScheduleViewController, FavoriteEventsStore) {
        let queue = try DatabaseQueue()
        let database = try AppDatabase(queue)
        let store = EventStore(writer: database.dbWriter, reader: database.reader)
        let favorites = FavoriteEventsStore(writer: queue, reader: queue)
        Container.shared.favoriteEventsStore.register { favorites }
        try await store.deleteAllAndInsert(events.map { $0.toRecord() })
        for event in events {
            try await favorites.createFavoriteEvent(eventID: event.id)
        }
        let controller = UserScheduleViewController()
        controller.loadViewIfNeeded()
        return (controller, favorites)
    }

    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<100 {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Favorites did not update within one second.")
    }

    private func event(id: Int, startDate: Date?) -> Event {
        var event = Event(id: id, name: "Favorite \(id)")
        event.startDate = startDate
        return event
    }

    private func date(day: Int, hour: Int = 0) -> Date {
        Calendar.autoupdatingCurrent.date(from: DateComponents(year: 2030, month: 5, day: day, hour: hour))!
    }
}
