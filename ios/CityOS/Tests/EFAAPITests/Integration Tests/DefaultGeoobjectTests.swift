import XCTest
@testable import EFAAPI

@MainActor
final class DefaultGeoobjectTests: IntegrationTestCase {
    func test_basic_request() async throws {
        let service = DefaultTransitService(loader: defaultLoader())
        let line: StatelessLineIdentifier = "ddb:90E31: :R:j23"
        let response = try await service.geoObject(lines: [line])
        XCTAssertEqual(response.language.count, 2)
    }
}
