import Foundation
import XMLCoder
import ModernNetworking
import CoreLocation

public enum Station {
    public typealias ID = Int
}

public protocol TransitService: AnyObject {
    
    func findTransitLocation(for searchTerm: String, filtering objectFilter: ObjectFilter) async throws -> [TransitLocation]
    
    func departureMonitor(
        id: Station.ID
    ) async throws -> DepartureMonitorData
    
    func findTransitLocation(
        for coordinate: CLLocationCoordinate2D,
        filtering objectFilter: ObjectFilter,
        maxNumberOfResults: Int
    ) async throws -> [TransitLocation]
    
    func sendTripRequest(
        origin: String,
        destination: String,
        config: TripRequest.Configuration,
        tripDate: TripDate
    ) async throws -> TripResponse
    
    func geoObject(
        lines: [LineIdentifiable]
    ) async throws -> GeoITDRequest
    
}
