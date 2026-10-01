//
//  LocationServiceTests.swift
//
//
//  Created by Codex on 27.06.26.
//

import CoreLocation
import XCTest

@testable import Core

nonisolated final class LocationServiceTests: XCTestCase {

    @MainActor
    func testLocationsCanBeConsumedByMultipleTasks() async throws {
        let service = DefaultLocationService(locationManager: CLLocationManager())
        let expectedLocation = CLLocation(latitude: 51.451530, longitude: 6.626131)
        let firstStream = service.locations
        let secondStream = service.locations

        async let firstLocation = nextLocation(matching: expectedLocation, from: firstStream)
        async let secondLocation = nextLocation(matching: expectedLocation, from: secondStream)

        service.locationManager(CLLocationManager(), didUpdateLocations: [expectedLocation])

        let receivedLocations = try await [firstLocation, secondLocation]

        XCTAssertEqual(receivedLocations.map(\.coordinate.latitude), Array(repeating: expectedLocation.coordinate.latitude, count: 2))
        XCTAssertEqual(receivedLocations.map(\.coordinate.longitude), Array(repeating: expectedLocation.coordinate.longitude, count: 2))
    }

    @MainActor
    func testCoreLocationObjectSubscriptionsDoNotRetainTheirOwner() async {
        var model: CoreLocationObject? = CoreLocationObject()
        weak var retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

}

private func nextLocation(
    matching expectedLocation: CLLocation,
    from stream: AsyncThrowingStream<CLLocation, Error>
) async throws -> CLLocation {
    for try await location in stream {
        guard location.coordinate.latitude == expectedLocation.coordinate.latitude,
              location.coordinate.longitude == expectedLocation.coordinate.longitude else {
            continue
        }

        return location
    }

    XCTFail("Expected location stream to emit the requested location.")
    return expectedLocation
}
