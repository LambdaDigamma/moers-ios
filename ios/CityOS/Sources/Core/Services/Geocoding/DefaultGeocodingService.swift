//
//  DefaultGeocodingService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import OSLog

public enum GeocodingError: Error {
    case noPlacemarkFound
}

public class DefaultGeocodingService: GeocodingService {
    
    private let geocoder: CLGeocoder
    private let logger: Logger
    
    public init(geocoder: CLGeocoder = CLGeocoder()) {
        self.geocoder = geocoder
        self.logger = Logger(.coreApi)
    }
    
    public func placemark(from location: CLLocation) async throws -> CLPlacemark {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                logger.error("No placemark found for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                throw GeocodingError.noPlacemarkFound
            }
            return placemark
        } catch {
            logger.error("Error while reverse geocoding location: \(error.localizedDescription, privacy: .private)")
            throw error
        }
    }
    
}
