import Core
import CoreLocation
import FactoryKit
import XCTest
@testable import FuelFeature

nonisolated final class FuelPriceDashboardViewModelTests: XCTestCase {
    
    @MainActor
    func testLoadUsesFallbackLocationForFuelStationsAfterCurrentLocationFailure() async {
        let locationService = FailingThenSuspendingLocationService()
        let petrolService = RecordingPetrolService(stations: [
            PetrolStation.stub(withID: "station")
                .setting(\.isOpen, to: true)
                .setting(\.price, to: 1.50)
        ])
        
        Container.shared.locationService.register { locationService }
        Container.shared.geocodingService.register {
            StaticGeocodingService(defaultPlacemark: CoreSettings.defaultPlacemark())
        }
        Container.shared.petrolService.register { petrolService }
        
        let viewModel = FuelPriceDashboardViewModel()
        let loadCompleted = expectation(description: "petrol dashboard load completes")
        let loadTask = Task {
            await viewModel.load()
            loadCompleted.fulfill()
        }
        
        await fulfillment(of: [loadCompleted], timeout: 1.0)
        loadTask.cancel()
        
        defer {
            Container.shared.locationService.reset()
            Container.shared.geocodingService.reset()
            Container.shared.petrolService.reset()
        }
        
        guard let data = viewModel.data.value else {
            XCTFail("Expected petrol dashboard data to be loaded.")
            return
        }
        
        XCTAssertEqual(data.numberOfStations, 1)
        XCTAssertEqual(data.averagePrice, 1.50, accuracy: 0.000_001)
        XCTAssertEqual(locationService.currentLocationRequestCount, 1)
        XCTAssertEqual(locationService.locationSubscriptionCount, 1)
        XCTAssertEqual(petrolService.requestedCoordinates.count, 1)
        
        guard let requestedCoordinate = petrolService.requestedCoordinates.first else {
            XCTFail("Expected a fuel station request coordinate.")
            return
        }
        
        XCTAssertEqual(
            requestedCoordinate.latitude,
            CoreSettings.regionCenter.latitude,
            accuracy: 0.000_001
        )
        XCTAssertEqual(
            requestedCoordinate.longitude,
            CoreSettings.regionCenter.longitude,
            accuracy: 0.000_001
        )
    }
    
}
