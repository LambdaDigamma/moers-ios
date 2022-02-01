//
//  CoreSettings.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import MapKit

public class CoreSettings {
    
    public static let regionCenter: CLLocationCoordinate2D = .init(
        latitude: 51.459167,
        longitude: 6.619722
    )
    
    public static let regionLocation: CLLocation = .init(
        latitude: regionCenter.latitude,
        longitude: regionCenter.longitude
    )
    
}

public extension CoreSettings {
    
    static func defaultRegion() -> MKCoordinateRegion {
        return MKCoordinateRegion(center: Self.regionCenter, latitudinalMeters: 8_000, longitudinalMeters: 8_000)
    }
    
}
