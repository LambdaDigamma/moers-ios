import Core
import CoreLocation
import XCTest

@MainActor
final class OnboardingLocationService: LocationService {
    let authorizationStatus: CLAuthorizationStatus
    private let started: XCTestExpectation?
    private let terminated: XCTestExpectation?
    private let locationStarted: XCTestExpectation?
    private let locationTerminated: XCTestExpectation?

    init(
        status: CLAuthorizationStatus = .notDetermined,
        started: XCTestExpectation? = nil,
        terminated: XCTestExpectation? = nil,
        locationStarted: XCTestExpectation? = nil,
        locationTerminated: XCTestExpectation? = nil
    ) {
        self.authorizationStatus = status
        self.started = started
        self.terminated = terminated
        self.locationStarted = locationStarted
        self.locationTerminated = locationTerminated
    }

    var authorizationStatuses: AsyncStream<CLAuthorizationStatus> {
        let started = started
        let terminated = terminated
        return AsyncStream { continuation in
            continuation.onTermination = { _ in terminated?.fulfill() }
            continuation.yield(authorizationStatus)
            started?.fulfill()
        }
    }

    var locations: AsyncThrowingStream<CLLocation, Error> {
        let started = locationStarted
        let terminated = locationTerminated
        return AsyncThrowingStream { continuation in
            continuation.onTermination = { _ in terminated?.fulfill() }
            started?.fulfill()
        }
    }

    func requestWhenInUseAuthorization() {}
    func requestCurrentLocation() {}
    func stopMonitoring() {}
}
