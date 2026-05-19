//
//  FavoriteEventsStoreTests.swift
//
//
//  Created by Lennart Fischer on 29.04.23.
//

import Foundation
import Combine
import XCTest
import Factory
import Core
@testable import MMEvents

final class FavoriteEventsStoreTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        Container.shared.currentDateProvider.reset()
        super.tearDown()
    }

    func testEventIsLiked() async throws {

        let db = MemoryDatabase.default()

        let eventStore = EventStore(writer: db, reader: db)
        let favoriteEventsStore = FavoriteEventsStore(writer: db, reader: db)

        let event = Event.stub(withID: 1)

        try await eventStore.insert(event)
        try await favoriteEventsStore.createFavoriteEvent(eventID: event.id)

        let isFavorite = try await favoriteEventsStore.isFavorite(eventID: event.id)

        XCTAssertTrue(isFavorite)

    }

    func testDeleteFavoriteEvent() async throws {

        let db = MemoryDatabase.default()

        let eventStore = EventStore(writer: db, reader: db)
        let favoriteEventsStore = FavoriteEventsStore(writer: db, reader: db)

        let event = Event.stub(withID: 1)

        try await eventStore.insert(event)
        try await favoriteEventsStore.createFavoriteEvent(eventID: event.id)

        let isFavorite = try await favoriteEventsStore.isFavorite(eventID: event.id)

        XCTAssertTrue(isFavorite)

    }

    func testToggleFavoriteEvent() async throws {

        let db = MemoryDatabase.default()

        let eventStore = EventStore(writer: db, reader: db)
        let favoriteEventsStore = FavoriteEventsStore(writer: db, reader: db)

        let event = Event.stub(withID: 1)

        try await eventStore.insert(event)

        try await favoriteEventsStore.toggleFavoriteEvent(eventID: event.id)

        var isFavorite = try await favoriteEventsStore.isFavorite(eventID: event.id)

        XCTAssertTrue(isFavorite)

        try await favoriteEventsStore.toggleFavoriteEvent(eventID: event.id)

        isFavorite = try await favoriteEventsStore.isFavorite(eventID: event.id)

        XCTAssertFalse(isFavorite)

    }

    func testObserveFavoriteEventsDoesNotEmitAgainWhenCurrentDateAdvancesWithinSameDayAndYear() async throws {

        let db = MemoryDatabase.default()

        let eventStore = EventStore(writer: db, reader: db)
        let favoriteEventsStore = FavoriteEventsStore(writer: db, reader: db)
        let currentDateProvider = MMEventsTestCurrentDateProvider(
            now: makeDate(year: 2026, month: 5, day: 22, hour: 10)
        )

        Container.shared.currentDateProvider.register { currentDateProvider }

        let event = Event.stub(withID: 1)
            .setting(\.startDate, to: makeDate(year: 2026, month: 5, day: 22, hour: 12))

        try await eventStore.insert(event)
        try await favoriteEventsStore.createFavoriteEvent(eventID: event.id)

        let initialEmission = expectation(description: "Initial favorite events emitted")
        let unexpectedSameDayEmission = expectation(description: "Same-day tick should not emit favorite events again")
        unexpectedSameDayEmission.isInverted = true

        var hasReceivedInitialEmission = false

        favoriteEventsStore
            .observeFavoriteEvents()
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Favorite events observation failed: \(error)")
                }
            } receiveValue: { favoriteEvents in
                guard favoriteEvents.map(\.event.id) == [Int64(event.id)] else {
                    return
                }

                if hasReceivedInitialEmission {
                    unexpectedSameDayEmission.fulfill()
                } else {
                    hasReceivedInitialEmission = true
                    initialEmission.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [initialEmission], timeout: 1)

        currentDateProvider.now = makeDate(year: 2026, month: 5, day: 22, hour: 18)

        await fulfillment(of: [unexpectedSameDayEmission], timeout: 0.2)
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {

        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour

        return components.date ?? Date()
    }

}
