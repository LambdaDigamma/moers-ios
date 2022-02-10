//
//  CLLocationCoordinate2D+Extensions.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

#if canImport(CoreLocation)

import CoreLocation

extension CLLocationCoordinate2D: CustomStringConvertible {
    
    public var description: String {
        return "Latitude: \(self.latitude), Longitude: \(self.longitude)"
    }
    
}

#endif
