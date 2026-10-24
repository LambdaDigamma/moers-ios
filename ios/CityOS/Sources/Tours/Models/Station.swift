//
//  Station.swift
//  
//
//  Created by Lennart Fischer on 18.12.20.
//

import Foundation
import CoreLocation

public struct Station: Codable, Identifiable {
    
    public typealias ID = Int
    
    public var id: ID
    public var name: String
    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
    
    public init(id: ID, name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
