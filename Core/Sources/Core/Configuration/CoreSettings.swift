//
//  CoreSettings.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import MapKit
import Contacts
import Factory

public class CoreSettings {
    
    public static let appName: String = "Mein Moers"
    public static let regionName: String = "Moers"
    
    public static let regionCenter: CLLocationCoordinate2D = .init(
        latitude: 51.459167,
        longitude: 6.619722
    )
    
    public static let regionLocation: CLLocation = .init(
        latitude: regionCenter.latitude,
        longitude: regionCenter.longitude
    )
    
    public static var userDefaults = UserDefaults.standard
    
}

public extension CoreSettings {
    
    static func defaultRegion() -> MKCoordinateRegion {
        return MKCoordinateRegion(center: Self.regionCenter, latitudinalMeters: 8_000, longitudinalMeters: 8_000)
    }
    
    static func defaultPlacemark() -> CLPlacemark {
        
        let address = CNMutablePostalAddress()
        
        address.city = CoreSettings.regionName
        address.street = "Musterstraße"
        address.isoCountryCode = "DE"
        
        return CLPlacemark(
            location: CoreSettings.regionLocation,
            name: regionName,
            postalAddress: address
        )
        
    }
    
}

public extension Container {
    
    static let geocodingService = Factory {
        
        let service = StaticGeocodingService()
        
        return service as GeocodingService
    }
    
}
