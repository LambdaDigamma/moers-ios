import Events
import Observation
import SwiftUI
import XCTest
@testable import moers_festival

@MainActor
final class UserScheduleFilterTests: XCTestCase {
    private var previousFilter: Any?

    override func setUp() async throws {
        try await super.setUp()
        previousFilter = UserDefaults.standard.object(forKey: "favoritesFilter")
        UserDefaults.standard.removeObject(forKey: "favoritesFilter")
    }

    override func tearDown() async throws {
        UserDefaults.standard.set(previousFilter, forKey: "favoritesFilter")
        try await super.tearDown()
    }

    func testBindingEditsPersistAndResetTheSavedFilter() async throws {
        let saved = EventFilter(venueIDs: [42])
        UserDefaults.standard.set(try JSONEncoder().encode(saved), forKey: "favoritesFilter")
        @Bindable var model = UserScheduleFilter()
        XCTAssertEqual(model.value, saved)

        $model.value.venueIDs.wrappedValue.insert(43)
        $model.value.showOnlyFavorites.wrappedValue = true
        let persisted = try XCTUnwrap(UserDefaults.standard.data(forKey: "favoritesFilter"))
        let expected = EventFilter(venueIDs: [42, 43], showOnlyFavorites: true)
        XCTAssertEqual(try JSONDecoder().decode(EventFilter.self, from: persisted), expected)
        XCTAssertEqual(UserScheduleFilter().value, expected)

        $model.value.wrappedValue = .empty
        XCTAssertEqual(UserScheduleFilter().value, .empty)
    }

    func testBindingEditsNotifyObservation() async {
        @Bindable var model = UserScheduleFilter()
        let changed = expectation(description: "Filter change is observed")
        withObservationTracking {
            _ = model.value
        } onChange: {
            changed.fulfill()
        }

        $model.value.venueIDs.wrappedValue.insert(42)
        await fulfillment(of: [changed], timeout: 1)
    }

    func testEqualEditsDoNotNotifyObservation() async {
        @Bindable var model = UserScheduleFilter()
        let changed = expectation(description: "Equal filter does not change")
        changed.isInverted = true
        withObservationTracking {
            _ = model.value
        } onChange: {
            changed.fulfill()
        }

        $model.value.wrappedValue = .empty
        await fulfillment(of: [changed], timeout: 0.05)
        XCTAssertNil(UserDefaults.standard.data(forKey: "favoritesFilter"))
    }
}
