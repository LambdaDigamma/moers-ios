import XCTest
@testable import EFAAPI

@MainActor
final class DefaultTransitServiceTests: IntegrationTestCase {
    func test_execute_stop_finder_request_list() async throws {
        let service = DefaultTransitService(loader: defaultLoader())
        let response = try await service.sendRawStopFinderRequest(searchText: "Aachen Hbf")
        XCTAssertEqual(response.language.count, 2)
    }

    func test_execute_trip_request_identified() async throws {
        let service = DefaultTransitService(loader: defaultLoader())
        let response = try await service.sendTripRequest(origin: 20036308, destination: 20016032, tripDate: .departure(Date()))
        XCTAssertEqual(response.language.count, 2)
    }
}
