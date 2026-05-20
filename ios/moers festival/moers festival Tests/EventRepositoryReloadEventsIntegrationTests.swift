//
//  EventRepositoryReloadEventsIntegrationTests.swift
//  moers festival Tests
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import GRDB
import MMEvents
import XCTest
@testable import moers_festival

final class EventRepositoryReloadEventsIntegrationTests: XCTestCase {

    func testReloadEventsStoresEventsPlaces() async throws {
        let databaseQueue = try DatabaseQueue()
        let appDatabase = try AppDatabase(databaseQueue)
        let store = EventStore(writer: appDatabase.dbWriter, reader: appDatabase.reader)
        let placeStore = PlaceStore(writer: appDatabase.dbWriter, reader: appDatabase.reader)
        let place = makePlace(id: 1, name: "Bøllwerk Bühne")
        var event = Event(
            id: 10,
            name: "Gellért Fresh Install Quartet",
            startDate: makeDate(year: 2030, month: 5, day: 17),
            artists: ["Straße Artist"],
            placeID: place.id
        )
        event.place = place

        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([event])),
            placeStore: placeStore,
            pageStore: nil
        )

        try await repository.reloadEvents()

        let titleResults = try await repository.searchEvents(query: "fresh install")
        let artistResults = try await repository.searchEvents(query: "strasse")
        let venueResults = try await repository.searchEvents(query: "bollwerk")
        let normalizedTitleResults = try await repository.searchEvents(query: "gellert")

        XCTAssertEqual(titleResults.map(\.id), [10])
        XCTAssertEqual(artistResults.map(\.id), [10])
        XCTAssertEqual(venueResults.map(\.id), [10])
        XCTAssertEqual(normalizedTitleResults.map(\.id), [10])

        let counts = try await databaseQueue.read { db in
            (
                events: try EventRecord.fetchCount(db),
                places: try PlaceRecord.fetchCount(db)
            )
        }

        XCTAssertEqual(counts.events, 1)
        XCTAssertEqual(counts.places, 1)
    }

    private func makePlace(id: Place.ID, name: String) -> Place {
        Place(
            id: id,
            lat: 51.451,
            lng: 6.631,
            name: name,
            streetName: "Street",
            streetNumber: "\(id)",
            streetAddition: nil,
            postalCode: "47441",
            postalTown: "Moers",
            countryCode: "DE",
            tags: "",
            url: nil,
            phone: nil,
            validatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        )
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int
    ) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12

        return components.date ?? Date()
    }

}
