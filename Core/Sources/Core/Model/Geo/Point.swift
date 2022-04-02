//
//  Point.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation

#if canImport(CoreLocation)
import CoreLocation
#endif

/// A Point represents a coordinate of latitude and
/// longitude and optionally elevation in the coordinate
/// system WGS 84 using the GeoJSON standard.
public struct Point: Codable, Equatable, Hashable {
    
    public var latitude: Double
    public var longitude: Double
    
    public init(
        latitude: Double,
        longitude: Double
    ) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinates: [Double] = try container.decode([Double].self, forKey: .coordinates)
        
        if let longitude = coordinates[safeIndex: 0] {
            self.longitude = longitude
        } else {
            throw GeoJSONDecodingError.pointInvalidNumberOfCoordinates
        }
        
        if let latitude = coordinates[safeIndex: 1] {
            self.latitude = latitude
        } else {
            throw GeoJSONDecodingError.pointInvalidNumberOfCoordinates
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode("Point", forKey: .type)
        try container.encode([
            self.longitude,
            self.latitude
        ], forKey: .coordinates)
        
    }
    
    public enum CodingKeys: String, CodingKey {
        case type = "type"
        case coordinates = "coordinates"
    }
    
    #if canImport(CoreLocation)
    
    public init(
        from coordinate: CLLocationCoordinate2D
    ) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    public func toCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
    
    #endif
    
}

#if canImport(CoreLocation)

public extension CLLocationCoordinate2D {
    
    func toPoint() -> Point {
        return Point(
            from: self
        )
    }
    
}

#endif
