import XCTest
@testable import EFAAPI

@MainActor
final class DefaultDepartureMonitorTests: IntegrationTestCase {
    func test_departureMonitorRequest() async throws {
        let service = DefaultTransitService(loader: defaultLoader())
        let response = try await service.sendRawDepartureMonitorRequest(id: 20016032)
        XCTAssertEqual(response.language.count, 2)
    }
}
