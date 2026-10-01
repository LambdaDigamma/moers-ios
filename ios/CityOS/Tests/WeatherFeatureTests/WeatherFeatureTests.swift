import XCTest
@testable import WeatherFeature

@MainActor
final class WeatherFeatureTests: XCTestCase {
    func testExample() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(WeatherFeature().text, "Hello, World!")
    }
}
