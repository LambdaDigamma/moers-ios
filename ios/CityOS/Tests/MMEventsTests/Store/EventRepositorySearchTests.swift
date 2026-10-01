//
//  EventRepositorySearchTests.swift
//
//
//  Created by Codex on 19.05.26.
//

import Foundation
import GRDB
import XCTest
@testable import MMEvents

@MainActor
final class EventRepositorySearchTests: XCTestCase {

    func testSearchMatchesTitleArtistAndVenue() async throws {

        let (repository, store, placeStore) = makeRepository()

        try await placeStore.updateOrCreate([
            makePlace(id: 1, name: "Main Hall").toRecord(),
            makePlace(id: 2, name: "Open Air Stage").toRecord()
        ])

        try await store.deleteAllAndInsert([
            makeEvent(id: 1, name: "Morning Set", artists: ["Alpha Ensemble"], placeID: 1).toRecord(),
            makeEvent(id: 2, name: "Late Quartet", artists: ["Beta Trio"], placeID: 1).toRecord(),
            makeEvent(id: 3, name: "Solo Piece", artists: ["Gamma"], placeID: 2).toRecord()
        ])

        try await assertSearch(query: "quartet", in: repository, ids: [2])
        try await assertSearch(query: "alpha", in: repository, ids: [1])
        try await assertSearch(query: "open air", in: repository, ids: [3])
    }

    func testSearchMatchesNormalizedDiacriticsAndSpecialFolding() async throws {

        let (repository, store, placeStore) = makeRepository()

        try await placeStore.updateOrCreate([
            makePlace(id: 1, name: "Straße Stage").toRecord(),
            makePlace(id: 2, name: "Wo die wilden Frösche klatschen").toRecord(),
            makePlace(id: 3, name: "Plain Hall").toRecord()
        ])

        try await store.deleteAllAndInsert([
            makeEvent(
                id: 1,
                name: "Gellért Quartet 100%_\\",
                artists: ["Accent Ensemble"],
                placeID: 3
            ).toRecord(),
            makeEvent(
                id: 2,
                name: "Special Character Set",
                artists: ["Straße Collective"],
                placeID: 3
            ).toRecord(),
            makeEvent(
                id: 3,
                name: "Venue Folding Session",
                artists: ["Plain Artist"],
                placeID: 1
            ).toRecord(),
            makeEvent(
                id: 4,
                name: "Venue Diacritic Session",
                artists: ["Plain Artist"],
                placeID: 2
            ).toRecord()
        ])

        try await assertSearch(query: "gellert", in: repository, ids: [1])
        try await assertSearch(query: "strasse", in: repository, ids: [2, 3])
        try await assertSearch(query: "frosche", in: repository, ids: [4])
        try await assertSearch(query: "100%_\\", in: repository, ids: [1])
    }

    func testSearchReflectsUpdatedEventTextFromBaseTables() async throws {

        let (repository, store, placeStore) = makeRepository()

        try await placeStore.updateOrCreate([
            makePlace(id: 1, name: "Current Venue").toRecord()
        ])
        try await store.deleteAllAndInsert([
            makeEvent(
                id: 1,
                name: "Old Device Title",
                artists: ["Old Artist"],
                placeID: 1
            ).toRecord()
        ])

        try await assertSearch(query: "old device", in: repository, ids: [1])
        try await assertSearch(query: "old artist", in: repository, ids: [1])

        try await store.updateOrCreate([
            makeEvent(
                id: 1,
                name: "Current Real Device Title",
                artists: ["Current Artist"],
                placeID: 1
            ).toRecord()
        ])

        try await assertSearch(query: "real device", in: repository, ids: [1])
        try await assertSearch(query: "current artist", in: repository, ids: [1])
        try await assertSearch(query: "old device", in: repository, ids: [])
        try await assertSearch(query: "old artist", in: repository, ids: [])
    }

    func testPlaceUpdateIsReflectedInSearchView() async throws {

        let (repository, store, placeStore) = makeRepository()

        try await placeStore.updateOrCreate([
            makePlace(id: 1, name: "Old Venue").toRecord()
        ])
        try await store.deleteAllAndInsert([
            makeEvent(
                id: 1,
                name: "Venue Rename Event",
                artists: ["Venue Artist"],
                placeID: 1
            ).toRecord()
        ])

        try await assertSearch(query: "old venue", in: repository, ids: [1])

        try await placeStore.updateOrCreate([
            makePlace(id: 1, name: "New Venue").toRecord()
        ])

        try await assertSearch(query: "new venue", in: repository, ids: [1])
        try await assertSearch(query: "old venue", in: repository, ids: [])
    }

    func testPlaceInsertIsReflectedInSearchView() async throws {

        let (repository, store, placeStore) = makeRepository()

        try await store.deleteAllAndInsert([
            makeEvent(
                id: 1,
                name: "Late Venue Event",
                artists: ["Late Venue Artist"],
                placeID: 1
            ).toRecord()
        ])

        try await assertSearch(query: "late venue hall", in: repository, ids: [])

        try await placeStore.insert(makePlace(id: 1, name: "Late Venue Hall").toRecord())

        try await assertSearch(query: "late venue hall", in: repository, ids: [1])
    }

    func testPlaceWriteDoesNotRequireEventSearchTables() async throws {

        let database = MemoryDatabase(definitions: [
            PlaceTableDefinition()
        ]).create()
        let placeStore = PlaceStore(writer: database, reader: database)

        try await placeStore.updateOrCreate([
            makePlace(id: 1, name: "Standalone Venue").toRecord()
        ])

        let places = try await placeStore.fetch()

        XCTAssertEqual(places.map(\.name), ["Standalone Venue"])
    }

    func testSearchRanksExactPrefixContainsTitleBeforeArtistBeforeVenueThenDateAndTitle() async throws {

        let (repository, store, placeStore) = makeRepository()

        try await placeStore.updateOrCreate([
            makePlace(id: 1, name: "Target Room").toRecord(),
            makePlace(id: 2, name: "Other Room").toRecord()
        ])

        try await store.deleteAllAndInsert([
            makeEvent(
                id: 1,
                name: "Midnight Target",
                startDate: makeDate(year: 2030, month: 5, day: 14),
                artists: ["Other Artist"],
                placeID: 2
            ).toRecord(),
            makeEvent(
                id: 2,
                name: "Target Later",
                startDate: makeDate(year: 2030, month: 5, day: 18),
                artists: ["Other Artist"],
                placeID: 2
            ).toRecord(),
            makeEvent(
                id: 3,
                name: "Target Earlier",
                startDate: makeDate(year: 2030, month: 5, day: 17),
                artists: ["Other Artist"],
                placeID: 2
            ).toRecord(),
            makeEvent(
                id: 4,
                name: "Artist Match",
                startDate: makeDate(year: 2030, month: 5, day: 16),
                artists: ["Target Artist"],
                placeID: 2
            ).toRecord(),
            makeEvent(
                id: 5,
                name: "Venue Match",
                startDate: makeDate(year: 2030, month: 5, day: 15),
                artists: ["Other Artist"],
                placeID: 1
            ).toRecord(),
            makeEvent(
                id: 6,
                name: "Target",
                startDate: makeDate(year: 2030, month: 5, day: 19),
                artists: ["Other Artist"],
                placeID: 2
            ).toRecord()
        ])

        let results = try await repository.searchEvents(query: "target")

        XCTAssertEqual(results.map(\.id), [6, 3, 2, 1, 4, 5])
    }

    func testSearchEscapesLikeWildcards() async throws {

        let (repository, store, _) = makeRepository()

        try await store.deleteAllAndInsert([
            makeEvent(id: 1, name: "100% Real").toRecord(),
            makeEvent(id: 2, name: "100X Real").toRecord(),
            makeEvent(id: 3, name: "Under_score").toRecord(),
            makeEvent(id: 4, name: "UnderXscore").toRecord(),
            makeEvent(id: 5, name: "Back\\Slash").toRecord(),
            makeEvent(id: 6, name: "BackXSlash").toRecord()
        ])

        try await assertSearch(query: "100%", in: repository, ids: [1])
        try await assertSearch(query: "Under_score", in: repository, ids: [3])
        try await assertSearch(query: "Back\\Slash", in: repository, ids: [5])
    }

    func testBlankRepositorySearchReturnsEmpty() async throws {

        let (repository, store, _) = makeRepository()

        try await store.deleteAllAndInsert([
            makeEvent(
                id: 1,
                name: "Later Event",
                startDate: makeDate(year: 2030, month: 5, day: 18)
            ).toRecord(),
            makeEvent(
                id: 2,
                name: "Alpha Event",
                startDate: makeDate(year: 2030, month: 5, day: 17)
            ).toRecord(),
            makeEvent(
                id: 3,
                name: "Undated Event",
                startDate: nil
            ).toRecord()
        ])

        let results = try await repository.searchEvents(query: "   ")

        XCTAssertTrue(results.isEmpty)
    }

    func testSearchReturnsNoResults() async throws {

        let (repository, store, _) = makeRepository()

        try await store.deleteAllAndInsert([
            makeEvent(id: 1, name: "Morning Set").toRecord()
        ])

        let results = try await repository.searchEvents(query: "missing")

        XCTAssertTrue(results.isEmpty)
    }

    private func assertSearch(
        query: String,
        in repository: EventRepository,
        ids: [Event.ID],
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let events = try await repository.searchEvents(query: query)
        XCTAssertEqual(events.map(\.id), ids, file: file, line: line)
    }

    private func makeRepository() -> (
        repository: EventRepository,
        store: EventStore,
        placeStore: PlaceStore
    ) {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let placeStore = PlaceStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            placeStore: placeStore,
            pageStore: nil
        )

        return (repository, store, placeStore)
    }

    private func makeEvent(
        id: Event.ID,
        name: String,
        startDate: Date? = nil,
        artists: [String]? = nil,
        placeID: Place.ID? = nil
    ) -> Event {

        Event(
            id: id,
            name: name,
            startDate: startDate,
            artists: artists,
            placeID: placeID,
            updatedAt: makeDate(year: 2030, month: 5, day: 1)
        )
    }

    private func makePlace(
        id: Place.ID,
        name: String
    ) -> Place {

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
