//
//  StaticGeocodingService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import CoreLocation
import Combine
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
    /// can be set on the `StaticGeocodingService`. Publisher is received on the main queue.
    public func placemark(from location: CLLocation) -> AnyPublisher<CLPlacemark, Error> {
        
        return Deferred {
            return Future { promise in
                promise(self.loadPlacemark(location))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
}
