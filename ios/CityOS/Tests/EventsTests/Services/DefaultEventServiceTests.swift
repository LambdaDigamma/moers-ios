//
//  DefaultEventServiceTests.swift
//
//
//  Created by Lennart Fischer on 07.04.23.
//

import Foundation
import XCTest
import Core
import ModernNetworking
@testable import Events

@MainActor
final class DefaultEventServiceTests: XCTestCase {
    func testShowDecodesEventFromAsyncClient() async throws {
        let event = Event(id: 42, name: "Sample event")
        let loader = EncodingMockLoader(model: Resource(data: event))
        let service = DefaultEventService(loader)
        let response = try await service.show(event: 42, cacheMode: .cached)
        XCTAssertEqual(response.data.id, 42)
        XCTAssertEqual(response.data.name, "Sample event")
    }

    func testIndexDecodesEventsFromAsyncClient() async throws {
        let events = [Event(id: 1, name: "First"), Event(id: 2, name: "Second")]
        let resource = ResourceCollection(data: events, links: ResourceLinks(), meta: ResourceMeta())
        let service = DefaultEventService(EncodingMockLoader(model: resource))
        let response = try await service.index(cacheMode: .cached)
        XCTAssertEqual(response.data.map(\.id), [1, 2])
        XCTAssertEqual(response.data.map(\.name), ["First", "Second"])
    }

    func testIndexDecodesCityEventsResponse() async throws {
        let json = """
        {
          "data": [
            {
              "id": 9,
              "name": "Trödelmarkt Repelen",
              "startDate": "2026-06-28T09:00:00+00:00",
              "endDate": "2026-06-28T16:00:00+00:00",
              "description": "Komm nach Repelen: Hier wird Trödeln jedes Mal zum Erlebnis.",
              "subtitle": "Eintritt frei",
              "teaser": "Der Trödelmarkt in Repelen",
              "excerpt": "Der Trödelmarkt in Repelen",
              "pageId": null,
              "url": "https://moers.de/veranstaltungen/troedelmarkt-repelen-6",
              "calendarUrl": "https://moers.app/veranstaltungen/troedelmarkt-repelen-6.ics",
              "scheduleDisplay": "date_time",
              "category": "Märkte",
              "collection": "city",
              "attendanceMode": "offline",
              "isOnline": false,
              "isMultiDay": false,
              "artists": [],
              "locationName": "Markt Repelen",
              "street": "Markt 1",
              "postcode": "47445",
              "city": "Moers",
              "latitude": 51.467,
              "longitude": 6.603,
              "organisationName": "WMV Märkte & Mehr UG",
              "organisationSlug": "wmv-maerkte",
              "organisationLogoPath": "https://storage.moers.app/media/logo.jpg",
              "organizerPhone": "+49 2841 0000",
              "organizerEmail": "events@example.com",
              "organizerWebsite": "https://example.com",
              "headerImageUrl": "https://storage.moers.app/media/header.jpg",
              "createdAt": "2026-03-08T10:28:46+00:00",
              "updatedAt": "2026-06-28T08:00:14+00:00",
              "publishedAt": "2026-06-28T08:00:13+00:00"
            }
          ],
          "links": [
            {"url": null, "label": "&laquo; Previous", "page": null, "active": false},
            {"url": "https://moers.app/api/v1/events?page%5Bnumber%5D=1", "label": "1", "page": 1, "active": true}
          ],
          "meta": {
            "current_page": 1,
            "from": 1,
            "last_page": 1,
            "path": "https://moers.app/api/v1/events",
            "per_page": 30,
            "to": 30,
            "total": 118
          }
        }
        """
        let client = CapturingHTTPClient(data: Data(json.utf8))
        let service = DefaultEventService(client: client)

        let response = try await service.index(cacheMode: .revalidate, withPages: false)
        let event = try XCTUnwrap(response.data.first)
        let request = await client.requests.first

        XCTAssertEqual(request?.path, "events")
        XCTAssertEqual(request?.queryItems ?? [], [
            URLQueryItem(name: "page[size]", value: "30"),
            URLQueryItem(name: "page[number]", value: "1"),
        ])
        XCTAssertEqual(response.meta.total, 118)
        XCTAssertEqual(event.id, 9)
        XCTAssertEqual(event.name, "Trödelmarkt Repelen")
        XCTAssertEqual(event.category, "Märkte")
        XCTAssertEqual(event.collection, "city")
        XCTAssertEqual(event.attendanceMode, "offline")
        XCTAssertFalse(event.isOnline)
        XCTAssertFalse(event.isMultiDay)
        XCTAssertEqual(event.subtitle, "Eintritt frei")
        XCTAssertEqual(event.calendarURL, "https://moers.app/veranstaltungen/troedelmarkt-repelen-6.ics")
        XCTAssertEqual(event.extras?.location, "Markt Repelen")
        XCTAssertEqual(event.extras?.street, "Markt 1")
        XCTAssertEqual(event.extras?.postcode, "47445")
        XCTAssertEqual(event.extras?.place, "Moers")
        XCTAssertEqual(event.extras?.lat, 51.467)
        XCTAssertEqual(event.extras?.lng, 6.603)
        XCTAssertEqual(event.extras?.organizer, "WMV Märkte & Mehr UG")
        XCTAssertEqual(event.extras?.scheduleDisplay, .dateTime)
        XCTAssertEqual(event.organisationName, "WMV Märkte & Mehr UG")
        XCTAssertEqual(event.organisationSlug, "wmv-maerkte")
        XCTAssertEqual(event.organisationLogoPath, "https://storage.moers.app/media/logo.jpg")
        XCTAssertEqual(event.organizerPhone, "+49 2841 0000")
        XCTAssertEqual(event.organizerEmail, "events@example.com")
        XCTAssertEqual(event.organizerWebsite, "https://example.com")
        XCTAssertEqual(event.image?.absoluteString, "https://storage.moers.app/media/header.jpg")
        XCTAssertEqual(event.startDate, Self.date("2026-06-28T09:00:00+00:00"))
    }

    func testIndexPaginatesCityEventsResponse() async throws {
        let firstPage = """
        {
          "data": [
            {
              "id": 9,
              "name": "Trödelmarkt Repelen",
              "startDate": "2026-06-28T09:00:00+00:00"
            }
          ],
          "links": [],
          "meta": {
            "current_page": 1,
            "from": 1,
            "last_page": 2,
            "path": "https://moers.app/api/v1/events",
            "per_page": 30,
            "to": 30,
            "total": 31
          }
        }
        """
        let secondPage = """
        {
          "data": [
            {
              "id": 10,
              "name": "Sommerabend",
              "startDate": "2026-06-29T18:00:00+00:00"
            }
          ],
          "links": [],
          "meta": {
            "current_page": 2,
            "from": 31,
            "last_page": 2,
            "path": "https://moers.app/api/v1/events",
            "per_page": 30,
            "to": 31,
            "total": 31
          }
        }
        """
        let client = CapturingHTTPClient(responses: [Data(firstPage.utf8), Data(secondPage.utf8)])
        let service = DefaultEventService(client: client)

        let response = try await service.index(cacheMode: .revalidate, withPages: false)
        let requests = await client.requests

        XCTAssertEqual(response.data.map(\.id), [9, 10])
        XCTAssertEqual(response.meta.total, 31)
        XCTAssertEqual(requests.map(\.path), ["events", "events"])
        XCTAssertEqual(requests.map { $0.queryItems ?? [] }, [
            [
                URLQueryItem(name: "page[size]", value: "30"),
                URLQueryItem(name: "page[number]", value: "1"),
            ],
            [
                URLQueryItem(name: "page[size]", value: "30"),
                URLQueryItem(name: "page[number]", value: "2"),
            ],
        ])
    }

    func testIndexWithPagesKeepsFestivalContentEndpoint() async throws {
        let json = """
        {
          "data": [],
          "links": {"first": null, "last": null, "prev": null, "next": null},
          "meta": {
            "current_page": 1,
            "from": null,
            "last_page": 1,
            "links": [],
            "path": "https://moers.app/api/v1/festival/content",
            "per_page": 50,
            "to": null,
            "total": 0
          }
        }
        """
        let client = CapturingHTTPClient(data: Data(json.utf8))
        let service = DefaultEventService(client: client)

        _ = try await service.index(cacheMode: .revalidate, withPages: true)
        let request = await client.requests.first

        XCTAssertEqual(request?.path, "content")
        XCTAssertEqual(request?.queryItems, [])
    }

    func testShowDecodesBareCityEventResponse() async throws {
        let json = """
        {
          "id": 9,
          "name": "Trödelmarkt Repelen",
          "startDate": "2026-06-28T09:00:00+00:00",
          "endDate": "2026-06-28T16:00:00+00:00",
          "description": "Komm nach Repelen: Hier wird Trödeln jedes Mal zum Erlebnis.",
          "teaser": "Der Trödelmarkt in Repelen",
          "excerpt": "Der Trödelmarkt in Repelen",
          "pageId": null,
          "url": "https://moers.de/veranstaltungen/troedelmarkt-repelen-6",
          "scheduleDisplay": "date_time",
          "category": null,
          "artists": [],
          "locationName": "Markt Repelen",
          "street": "Markt 1",
          "postcode": "47445",
          "city": "Moers",
          "latitude": 51.467,
          "longitude": 6.603,
          "organisationName": "WMV Märkte & Mehr UG",
          "headerImageUrl": "https://storage.moers.app/media/header.jpg",
          "createdAt": "2026-03-08T10:28:46+00:00",
          "updatedAt": "2026-06-28T08:00:14+00:00",
          "publishedAt": "2026-06-28T08:00:13+00:00"
        }
        """
        let client = CapturingHTTPClient(data: Data(json.utf8))
        let service = DefaultEventService(client: client)

        let response = try await service.show(event: 9, cacheMode: .revalidate)
        let request = await client.requests.first

        XCTAssertEqual(request?.path, "events/9")
        XCTAssertEqual(response.data.id, 9)
        XCTAssertEqual(response.data.name, "Trödelmarkt Repelen")
        XCTAssertEqual(response.data.extras?.location, "Markt Repelen")
    }

    private static func date(_ value: String) -> Date? {
        ISO8601DateFormatter().date(from: value)
    }

}
