import Core
import CoreLocation
import XCTest

@MainActor
final class RecordingLocationService: LocationService {
    let authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    private(set) var requestCount = 0
    private(set) var subscriptionCount = 0
    var requested: XCTestExpectation?
    var terminated: XCTestExpectation?
    var requestedLocation: CLLocation?
    private var continuation: AsyncThrowingStream<CLLocation, Error>.Continuation?

    var authorizationStatuses: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { $0.finish() }
    }

    var locations: AsyncThrowingStream<CLLocation, Error> {
        subscriptionCount += 1
        return AsyncThrowingStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [terminated] _ in
                terminated?.fulfill()
            }
        }
    }

    func requestCurrentLocation() {
        requestCount += 1
        if let requestedLocation { continuation?.yield(requestedLocation) }
        requested?.fulfill()
    }

    func send(_ location: CLLocation) { continuation?.yield(location) }
    func finish() { continuation?.finish() }
    func requestWhenInUseAuthorization() {}
    func stopMonitoring() {}
}
