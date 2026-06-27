//
//  StaticGeocodingService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import CoreLocation
import MapKit

nonisolated public class StaticGeocodingService: GeocodingService {
    
    public var loadPlacemark: ((CLLocation) -> Result<CLPlacemark, Error>)
    
    public init(defaultPlacemark: CLPlacemark? = nil) {
        
        let `default`: CLPlacemark = MKPlacemark(coordinate: CoreSettings.regionCenter)
        
        self.loadPlacemark = { (_: CLLocation) in
            return .success(defaultPlacemark ?? `default`)
        }
        
    }
    
    /// Returns the placemark specified via the `loadPlacemark` closure that
    /// can be set on the `StaticGeocodingService`.
    public func placemark(from location: CLLocation) async throws -> CLPlacemark {
        return try loadPlacemark(location).get()
    }
    
}
