//
//  CoreSettings.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation

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
