import XCTest
@testable import Events

final class EventDecodingTests: XCTestCase {
    func testMissingNameRemainsADecodingError() {
        XCTAssertThrowsError(try Event.decoder.decode(Event.self, from: Data("{\"id\":42}".utf8)))
    }

    func testLocalizedNameDecodesFromCityPayload() throws {
        let event = try Event.decoder.decode(Event.self, from: Data("{\"id\":42,\"name\":{\"de\":\"Moers\",\"en\":\"Moers\"}}".utf8))
        XCTAssertEqual(event.name, "Moers")
    }

    func testStringCoordinatesAndUnknownScheduleDoNotRejectAnEvent() throws {
        let data = Data(#"{"id":42,"name":"Event","latitude":" 51.45 ","longitude":"6.63","scheduleDisplay":"new_mode"}"#.utf8)
        let event = try Event.decoder.decode(Event.self, from: data)
        XCTAssertEqual(event.extras?.lat, 51.45)
        XCTAssertEqual(event.extras?.lng, 6.63)
        XCTAssertNil(event.extras?.scheduleDisplay)
    }

    func testInvalidOptionalCoordinatesAreIgnored() throws {
        for coordinates in [#""latitude":"unknown","longitude":{}"#, #""latitude":91,"longitude":181"#, #""latitude":"NaN","longitude":"Infinity""#] {
            let data = Data("{\"id\":42,\"name\":\"Event\",\(coordinates)}".utf8)
            let event = try Event.decoder.decode(Event.self, from: data)
            XCTAssertNil(event.extras?.lat)
            XCTAssertNil(event.extras?.lng)
        }
    }

    func testNullOptionalCoordinatesAreIgnored() throws {
        let event = try Event.decoder.decode(Event.self, from: Data(#"{"id":42,"name":"Event","latitude":null,"longitude":null,"scheduleDisplay":null}"#.utf8))
        XCTAssertNil(event.extras?.lat)
        XCTAssertNil(event.extras?.lng)
    }

    func testMalformedRequiredIdentifierStillFails() {
        XCTAssertThrowsError(try Event.decoder.decode(Event.self, from: Data(#"{"id":{},"name":"Event"}"#.utf8)))
    }

    func testCityPresentationFieldsSurviveEncoding() throws {
        let event = Event(
            id: 42, name: "Event", description: "Description", excerpt: "Excerpt", teaser: "Teaser", subtitle: "Subtitle",
            calendarURL: "https://example.com/event.ics", collection: "city", attendanceMode: "offline", isOnline: true, isMultiDay: true,
            organisationName: "Organizer", organisationSlug: "organizer", organisationLogoPath: "https://example.com/logo.png",
            organizerStreet: "Street", organizerPostcode: "47441", organizerCity: "Moers", organizerPhone: "123",
            organizerEmail: "events@example.com", organizerWebsite: "https://example.com",
            createdAt: Date(timeIntervalSince1970: 1_791_400_500), updatedAt: Date(timeIntervalSince1970: 1_791_400_500)
        )
        let decoded = try Event.decoder.decode(Event.self, from: Event.encoder.encode(event))
        XCTAssertEqual(decoded.description, event.description)
        XCTAssertEqual(decoded.excerpt, event.excerpt)
        XCTAssertEqual(decoded.teaser, event.teaser)
        XCTAssertEqual(decoded.subtitle, event.subtitle)
        XCTAssertEqual(decoded.calendarURL, event.calendarURL)
        XCTAssertEqual(decoded.collection, event.collection)
        XCTAssertEqual(decoded.attendanceMode, event.attendanceMode)
        XCTAssertTrue(decoded.isOnline)
        XCTAssertTrue(decoded.isMultiDay)
        XCTAssertEqual(decoded.organisationName, event.organisationName)
        XCTAssertEqual(decoded.organisationSlug, event.organisationSlug)
        XCTAssertEqual(decoded.organisationLogoPath, event.organisationLogoPath)
        XCTAssertEqual(decoded.organizerStreet, event.organizerStreet)
        XCTAssertEqual(decoded.organizerPostcode, event.organizerPostcode)
        XCTAssertEqual(decoded.organizerCity, event.organizerCity)
        XCTAssertEqual(decoded.organizerPhone, event.organizerPhone)
        XCTAssertEqual(decoded.organizerEmail, event.organizerEmail)
        XCTAssertEqual(decoded.organizerWebsite, event.organizerWebsite)
        XCTAssertEqual(decoded.createdAt, event.createdAt)
    }
}
