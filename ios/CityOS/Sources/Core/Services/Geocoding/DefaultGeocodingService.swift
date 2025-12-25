//
//  DefaultGeocodingService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import Combine
import OSLog

public class DefaultGeocodingService: GeocodingService {
    
    private let geocoder: CLGeocoder
    private let logger: Logger
    
    public init(geocoder: CLGeocoder = CLGeocoder()) {
        self.geocoder = geocoder
        self.logger = Logger(.coreApi)
    }
    
    public func placemark(from location: CLLocation) -> AnyPublisher<CLPlacemark, Error> {
        
        return Deferred {
            Future { promise in
                self.geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    if let error = error {
                        self.logger.error("Error while reverse geocoding location: \(error.localizedDescription, privacy: .private)")
                        promise(.failure(error))
                    }
                    if let placemarks = placemarks, let placemark = placemarks.first {
                        promise(.success(placemark))
                    }
                }
            }
        }.eraseToAnyPublisher()
        
    }
    
}
