import CoreLocation
import Foundation
import XCTest
@testable import FuelFeature

@MainActor
final class DefaultPetrolServiceTests: ServiceTestCase {
    func test_getStations() async throws {
        try requireLiveIntegrationTests()
        let service = createService()
        let stations = try await service.getPetrolStations(
            coordinate: CLLocationCoordinate2D(latitude: 51.45165, longitude: 6.62628),
            radius: 25,
            sorting: .distance,
            type: .diesel
        )
        XCTAssertFalse(stations.isEmpty)
        XCTAssertEqual(service.lastLoadLocation?.coordinate.latitude, 51.45165)
        XCTAssertEqual(service.lastLoadLocation?.coordinate.longitude, 6.62628)
    }

    func test_getStation() async throws {
        try requireLiveIntegrationTests()
        let station = try await createService().getPetrolStation(id: "78705b10-1ce8-40ff-8cb8-77d7fc5687cc")
        XCTAssertEqual(station.id, "78705b10-1ce8-40ff-8cb8-77d7fc5687cc")
    }

    private func requireLiveIntegrationTests() throws {
        guard ProcessInfo.processInfo.environment["RUN_FUEL_INTEGRATION_TESTS"] == "1" else {
            throw XCTSkip("Live fuel API tests require RUN_FUEL_INTEGRATION_TESTS=1.")
        }
    }

    func createService() -> DefaultPetrolService {
        
        let apiKey = "0dfdfad3-7385-ef47-2ff6-ec0477872677"
        let service = DefaultPetrolService(apiKey: apiKey)
        
        return service
        
    }
    
}
