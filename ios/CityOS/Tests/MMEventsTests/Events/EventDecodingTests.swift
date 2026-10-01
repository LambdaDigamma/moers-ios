import XCTest
@testable import MMEvents

final class EventDecodingTests: XCTestCase {
    func testMissingNameRemainsADecodingError() {
        XCTAssertThrowsError(try Event.decoder.decode(Event.self, from: Data("{\"id\":42}".utf8)))
    }

    func testLocalizedNameDecodesFromCityPayload() throws {
        let event = try Event.decoder.decode(Event.self, from: Data("{\"id\":42,\"name\":{\"de\":\"Moers\",\"en\":\"Moers\"}}".utf8))
        XCTAssertEqual(event.name, "Moers")
    }
}
