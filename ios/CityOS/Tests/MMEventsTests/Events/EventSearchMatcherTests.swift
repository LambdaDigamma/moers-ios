//
//  EventSearchMatcherTests.swift
//
//
//  Created by Codex on 17.06.26.
//

import XCTest
@testable import MMEvents

final class EventSearchMatcherTests: XCTestCase {

    func testMatchesCityEventTitleArtistsLocationOrganizerAndCategory() {
        let event = Event(
            id: 1,
            name: "Hüsch-Lieder zum Klingen",
            description: "Texte und Lieder von Hanns Dieter Hüsch.",
            category: "Konzert",
            extras: EventExtras(
                location: "Haus der Demokratiegeschichte",
                street: "Kastell 5",
                postcode: "47441",
                place: "Moers",
                organizer: "Grafschafter Museum"
            ),
            artists: ["Stefan Pelzer-Florack"]
        )
        let matcher = EventSearchMatcher()

        XCTAssertTrue(matcher.matches(event, query: "huesch"))
        XCTAssertTrue(matcher.matches(event, query: "pelzer"))
        XCTAssertTrue(matcher.matches(event, query: "demokratiegeschichte"))
        XCTAssertTrue(matcher.matches(event, query: "grafschafter"))
        XCTAssertTrue(matcher.matches(event, query: "konzert"))
        XCTAssertTrue(matcher.matches(event, query: "kastell"))
        XCTAssertFalse(matcher.matches(event, query: "schlosstheater"))
    }

    func testExactMatchIndexesIncludeMetadataMatches() {
        let events = [
            Event(
                id: 1,
                name: "Hüsch-Lieder zum Klingen",
                extras: EventExtras(street: "Kastell 5")
            ),
            Event(
                id: 2,
                name: "Sommerabend",
                extras: EventExtras(location: "Neumarkt Denkmal")
            )
        ]
        let matcher = EventSearchMatcher()

        XCTAssertEqual(matcher.exactMatchIndexes(in: events, query: "kastell"), Set([0]))
        XCTAssertEqual(matcher.exactMatchIndexes(in: events, query: "neumarkt"), Set([1]))
    }

    func testMatchesNestedPlaceFallback() {
        var event = Event(
            id: 2,
            name: "Sommerabend",
            artists: []
        )
        event.place = Place(
            id: 10,
            lat: 51.451,
            lng: 6.631,
            name: "Schlosstheater Moers",
            streetName: "Kastell",
            streetNumber: "6",
            streetAddition: nil,
            postalCode: "47441",
            postalTown: "Moers",
            countryCode: "DE",
            tags: "",
            url: nil,
            phone: nil,
            validatedAt: nil,
            createdAt: nil,
            updatedAt: nil,
            deletedAt: nil
        )
        let matcher = EventSearchMatcher()

        XCTAssertTrue(matcher.matches(event, query: "schlosstheater"))
        XCTAssertTrue(matcher.matches(event, query: "47441"))
        XCTAssertTrue(matcher.matches(event, query: "moers"))
    }

}
