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
    
    nonisolated(unsafe) public static var userDefaults = UserDefaults.standard
    
}

public extension CoreSettings {

    static func defaultRegion() -> MKCoordinateRegion {
        return MKCoordinateRegion(center: Self.regionCenter, latitudinalMeters: 8_000, longitudinalMeters: 8_000)
    }

    /// A camera boundary that restricts the map to the greater Moers area.
    /// Falls back to the default 8km region when no locations are provided.
    static func cameraBoundary(for coordinates: [CLLocationCoordinate2D] = [], padding: Double = 0.3) -> MKMapView.CameraBoundary {

        guard !coordinates.isEmpty else {
            return MKMapView.CameraBoundary(coordinateRegion: defaultRegion())!
        }

        var minLat = coordinates[0].latitude
        var maxLat = minLat
        var minLng = coordinates[0].longitude
        var maxLng = minLng

        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLng = min(minLng, coord.longitude)
            maxLng = max(maxLng, coord.longitude)
        }

        let latPadding = max((maxLat - minLat) * padding, 0.02)
        let lngPadding = max((maxLng - minLng) * padding, 0.02)

        let sw = MKMapPoint(CLLocationCoordinate2D(latitude: minLat - latPadding, longitude: minLng - lngPadding))
        let ne = MKMapPoint(CLLocationCoordinate2D(latitude: maxLat + latPadding, longitude: maxLng + lngPadding))

        let rect = MKMapRect(
            x: min(sw.x, ne.x),
            y: min(sw.y, ne.y),
            width: abs(ne.x - sw.x),
            height: abs(ne.y - sw.y)
        )

        return MKMapView.CameraBoundary(mapRect: rect)!
    }

    nonisolated(unsafe) static let cameraZoomRange = MKMapView.CameraZoomRange(
        minCenterCoordinateDistance: 500,
        maxCenterCoordinateDistance: 30_000
    )
    
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
    
    var geocodingService: Factory<GeocodingService> { self { StaticGeocodingService() } }
    
//    static let geocodingService = Factory {
//
//        let service = StaticGeocodingService()
//
//        return service as GeocodingService
//    }
    
}
