import XCTest
@testable import EFAAPI

@MainActor
final class Playground: IntegrationTestCase {
    func testPlayground() async throws {
        let service = DefaultTransitService(loader: defaultLoader())
        let locations = try await service.findTransitLocation(for: "Moers Bahnhof", filtering: [.noFilter])
        XCTAssertFalse(locations.isEmpty)
    }
}
