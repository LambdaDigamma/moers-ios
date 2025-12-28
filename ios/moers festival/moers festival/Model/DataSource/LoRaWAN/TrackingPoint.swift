//
//  TrackingPoint.swift
//  moers festival
//
//  Created by Lennart Fischer on 25.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import CoreLocation

struct TrackingPoint: Codable {
    
    var time: Date
    var gatewayAltitude: Int
    var gatewayID: String
    var gatewayLatitude: Double
    var gatewayLongitude: Double
    var gatewayRSSI: Int
    var altitude: Int?
    var datarate: String
    var deviceID: String
    var geohash: String?
    var latitude: Double
    var longitude: Double
    var pax: Int?
    var sats: Int?
    var wifi: Int?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init() {
        self.time = Date()
        self.gatewayAltitude = 0
        self.gatewayID = ""
        self.gatewayLatitude = 0
        self.gatewayLongitude = 0
        self.gatewayRSSI = 0
        self.altitude = 0
        self.datarate = ""
        self.deviceID = ""
        self.geohash = ""
        self.latitude = 0
        self.longitude = 0
        self.pax = 0
        self.sats = 0
        self.wifi = 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time, forKey: .time)
        try container.encode(gatewayAltitude, forKey: .gatewayAltitude)
        try container.encode(gatewayID, forKey: .gatewayID)
        try container.encode(gatewayLatitude, forKey: .gatewayLatitude)
        try container.encode(gatewayLongitude, forKey: .gatewayLongitude)
        try container.encode(gatewayRSSI, forKey: .gatewayRSSI)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(datarate, forKey: .datarate)
        try container.encode(deviceID, forKey: .deviceID)
        try container.encode(geohash, forKey: .geohash)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(pax, forKey: .pax)
        try container.encode(sats, forKey: .sats)
        try container.encode(wifi, forKey: .wifi)
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init()
        self.time = try values.decode(Date.self, forKey: .time)
        self.gatewayAltitude = try values.decode(Int.self, forKey: .gatewayAltitude)
        self.gatewayID = try values.decode(String.self, forKey: .gatewayID)
        self.gatewayLatitude = try values.decode(Double.self, forKey: .gatewayLatitude)
        self.gatewayLongitude = try values.decode(Double.self, forKey: .gatewayLongitude)
        self.gatewayRSSI = try values.decode(Int.self, forKey: .gatewayRSSI)
        self.altitude = try values.decode(Int?.self, forKey: .altitude)
        self.datarate = try values.decode(String.self, forKey: .datarate)
        self.deviceID = try values.decode(String.self, forKey: .deviceID)
        self.geohash = try values.decode(String?.self, forKey: .geohash)
        self.latitude = try values.decode(Double.self, forKey: .latitude)
        self.longitude = try values.decode(Double.self, forKey: .longitude)
        
    }
    
    enum CodingKeys: String, CodingKey {
        
        case time = "time"
        case gatewayAltitude = "0_altitude"
        case gatewayID = "0_gtw_id"
        case gatewayLatitude = "0_latitude"
        case gatewayLongitude = "0_longitude"
        case gatewayRSSI = "0_rssi"
        case altitude = "alt"
        case datarate = "datarate"
        case deviceID = "dev_id"
        case geohash = "geohash"
        case latitude = "lat"
        case longitude = "lon"
        case pax = "pax"
        case sats = "sats"
        case wifi = "wifi"
        
    }
    
    static func randomInMoers() -> TrackingPoint {
        
        var trackingPoint = TrackingPoint()
        
        // Breitengrad: 51.4373
        // Längengrad: 6.6073
        
        // Breitengrad: 51.4623
        // Längengrad: 6.6630
        
        let latitude = Double.random(in: 51.4373...51.4623)
        let longitude = Double.random(in: 6.6073...6.6630)
        
        trackingPoint.latitude = latitude
        trackingPoint.longitude = longitude
        
        return trackingPoint
        
    }
    
}
