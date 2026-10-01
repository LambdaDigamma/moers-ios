import Core
import CoreLocation
import Foundation

@MainActor
final class FailingThenSuspendingLocationService: LocationService {
    
    private(set) var locationSubscriptionCount = 0
    private(set) var currentLocationRequestCount = 0
    
    var authorizationStatus: CLAuthorizationStatus {
        .authorizedWhenInUse
    }
    
    var authorizationStatuses: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            continuation.yield(.authorizedWhenInUse)
        }
    }
    
    var locations: AsyncThrowingStream<CLLocation, Error> {
        locationSubscriptionCount += 1
        let subscriptionNumber = locationSubscriptionCount
        
        return AsyncThrowingStream { continuation in
            if subscriptionNumber == 1 {
                continuation.finish(throwing: CLError(.locationUnknown))
            }
        }
    }
    
    func requestWhenInUseAuthorization() {}
    
    func requestCurrentLocation() {
        currentLocationRequestCount += 1
    }
    
    func stopMonitoring() {}
    
}
