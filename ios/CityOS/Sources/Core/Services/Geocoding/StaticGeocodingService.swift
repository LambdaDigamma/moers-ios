//
//  StaticGeocodingService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import CoreLocation
import Intents
import Contacts

public class StaticGeocodingService: GeocodingService {
    
    public var loadPlacemark: ((CLLocation) -> Result<CLPlacemark, Error>)
    
    public init(defaultPlacemark: CLPlacemark? = nil) {
        
        let `default` = CLPlacemark(location: CoreSettings.regionLocation, name: "Default", postalAddress: nil)
        
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
