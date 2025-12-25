//
//  TransitLocation.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable, @retroactive Hashable, Codable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.longitude == rhs.longitude
            && lhs.latitude == rhs.latitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude)
        hasher.combine(self.longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
}

public class TransitLocation: ObservableObject, Hashable, Equatable, CustomDebugStringConvertible, Codable {
    
    public var stationID: Station.ID?
    public var statelessIdentifier: StatelessIdentifier
    public var locationType: TransitLocationType
    public var name: String
    public var description: String
    public var coordinates: CLLocationCoordinate2D? = nil
    
    public init(odvNameElement: ODVNameElement) {
        
        self.stationID = odvNameElement.stopID ?? odvNameElement.id
        self.locationType = odvNameElement.anyType ?? .location
        self.name = odvNameElement.name
        self.description = "\(odvNameElement.locality ?? "") \(odvNameElement.streetName ?? "") \(odvNameElement.buildingNumber ?? "")"
        self.statelessIdentifier = odvNameElement.stateless
        
        if let latitude = odvNameElement.lat, let longitude = odvNameElement.lng {
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stationID = try container.decode(Station.ID?.self, forKey: .stationID)
        self.statelessIdentifier = try container.decode(StatelessIdentifier.self, forKey: .statelessIdentifier)
        self.locationType = try container.decode(TransitLocationType.self, forKey: .locationType)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.coordinates = try container.decode(CLLocationCoordinate2D?.self, forKey: .coordinates)
    }
    
    public init(
        stationID: Station.ID? = nil,
        statelessIdentifier: StatelessIdentifier = "",
        locationType: TransitLocationType = .location,
        name: String,
        description: String,
        coordinates: CLLocationCoordinate2D? = nil
    ) {
        self.stationID = stationID
        self.statelessIdentifier = statelessIdentifier
        self.locationType = locationType
        self.name = name
        self.description = description
        self.coordinates = coordinates
    }
    
    public static func == (lhs: TransitLocation, rhs: TransitLocation) -> Bool {
        return lhs.stationID == rhs.stationID
            && lhs.statelessIdentifier == rhs.statelessIdentifier
            && lhs.locationType == rhs.locationType
            && lhs.name == rhs.name
            && lhs.description == rhs.description
            && lhs.coordinates == rhs.coordinates
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(stationID)
        hasher.combine(statelessIdentifier)
        hasher.combine(locationType)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(coordinates)
    }
    
    public var debugDescription: String {
        return "TransitLocation(stationID: \(String(describing: stationID)), name: \(name))"
    }
    
    public enum CodingKeys: String, CodingKey {
        case stationID = "station_id"
        case statelessIdentifier = "stateless_identifier"
        case locationType = "location_type"
        case name = "name"
        case description = "description"
        case coordinates = "coordinates"
    }
    
}
