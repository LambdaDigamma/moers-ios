//
//  DefaultEventServiceCityAPITests.swift
//
//
//  Created by Codex on 17.06.26.
//

import Core
import Foundation
import ModernNetworking
import XCTest
@testable import MMEvents

@MainActor
final class DefaultEventServiceCityAPITests: XCTestCase {

    func testIndexDecodesCityEventsEnvelopeWithPaginationLinksArray() async throws {
        let loader = CityEventHTTPClient(json: """
        {
          "data": [
            {
              "id": 798,
              "name": "Hüsch-Lieder zum Klingen",
              "startDate": "2026-06-17T17:00:00+00:00",
              "endDate": "2026-06-17T18:30:00+00:00",
              "description": "Ein Abend mit Texten und Liedern.",
              "excerpt": "Ein Abend mit Texten.",
              "teaser": "Ein Abend mit Texten.",
              "subtitle": null,
              "pageId": null,
              "url": "https://moers.de/veranstaltungen/huesch-lieder",
              "calendarUrl": "data:text/calendar;base64,AAAA",
              "scheduleDisplay": "date_time",
              "showsDateComponent": true,
              "showsTimeComponent": true,
              "category": "Konzert",
              "collection": null,
              "attendanceMode": "offline",
              "isOnline": false,
              "isMultiDay": false,
              "artists": ["Stefan Pelzer-Florack"],
              "locationName": "Haus der Demokratiegeschichte",
              "street": "Kastell 5",
              "postcode": "47441",
              "city": "Moers",
              "latitude": 51.451,
              "longitude": 6.631,
              "organisationName": "Grafschafter Museum",
              "organisationSlug": null,
              "organisationLogoPath": null,
              "organizerStreet": "Kastell 9",
              "organizerPostcode": "47441",
              "organizerCity": "Moers",
              "organizerPhone": null,
              "organizerEmail": null,
              "organizerWebsite": null,
              "headerImageUrl": "https://moers.app/storage/header.jpg",
              "createdAt": "2026-06-01T10:00:00+00:00",
              "updatedAt": "2026-06-02T10:00:00+00:00",
              "publishedAt": "2026-06-03T10:00:00+00:00",
              "cancelledAt": null,
              "archivedAt": null,
              "deletedAt": null,
              "subEvents": null,
              "parentEvent": null
            }
          ],
          "links": [
            { "url": null, "label": "&laquo; Previous", "page": null, "active": false },
            { "url": "https://moers.app/api/v1/events?page%5Bnumber%5D=2", "label": "Next &raquo;", "page": 2, "active": false }
          ],
          "meta": {
            "current_page": 1,
            "from": 1,
            "last_page": 124,
            "path": "https://moers.app/api/v1/events",
            "per_page": 1,
            "to": 1,
            "total": 124
          }
        }
        """)
        let service = DefaultEventService(client: loader)

        let response = try await service.index(cacheMode: .cached, withPages: false)
        let event = try XCTUnwrap(response.data.first)

        let requests = await loader.requests
        XCTAssertEqual(requests.map(\.path), ["events"])
        XCTAssertEqual(response.meta.currentPage, 1)
        XCTAssertEqual(response.meta.lastPage, 124)
        XCTAssertEqual(event.id, 798)
        XCTAssertEqual(event.name, "Hüsch-Lieder zum Klingen")
        XCTAssertEqual(event.artists?.compactMap { $0 }, ["Stefan Pelzer-Florack"])
        XCTAssertEqual(event.extras?.location, "Haus der Demokratiegeschichte")
        XCTAssertEqual(event.extras?.organizer, "Grafschafter Museum")
        XCTAssertEqual(event.extras?.scheduleDisplay, .dateTime)
        XCTAssertEqual(event.displayLocationName, "Haus der Demokratiegeschichte")
        XCTAssertEqual(event.category, "Konzert")
        XCTAssertEqual(event.imagePath, "https://moers.app/storage/header.jpg")
        XCTAssertNotNil(event.startDate)
        XCTAssertNotNil(event.updatedAt)
    }

    func testShowDecodesDirectCityEventPayload() async throws {
        let loader = CityEventHTTPClient(json: """
        {
          "id": 42,
          "name": "Direkter API Termin",
          "startDate": "2026-06-17T17:00:00+00:00",
          "endDate": null,
          "description": null,
          "pageId": null,
          "url": null,
          "scheduleDisplay": "date",
          "category": null,
          "artists": [],
          "locationName": null,
          "street": "Rathausplatz 1",
          "postcode": null,
          "city": "Moers",
          "latitude": null,
          "longitude": null,
          "organisationName": "Stadt Moers",
          "headerImageUrl": null,
          "createdAt": null,
          "updatedAt": null,
          "publishedAt": null
        }
        """)
        let service = DefaultEventService(client: loader)

        let response = try await service.show(event: 42, cacheMode: .cached)

        let requests = await loader.requests
        XCTAssertEqual(requests.map(\.path), ["events/42"])
        XCTAssertEqual(response.data.name, "Direkter API Termin")
        XCTAssertNil(response.data.extras?.location)
        XCTAssertEqual(response.data.extras?.street, "Rathausplatz 1")
        XCTAssertEqual(response.data.displayLocationName, "Rathausplatz 1")
        XCTAssertEqual(response.data.extras?.organizer, "Stadt Moers")
        XCTAssertEqual(response.data.extras?.scheduleDisplay, .date)
    }

}
