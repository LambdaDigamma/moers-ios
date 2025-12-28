//
//  MoveableLocation.swift
//  moers festival
//
//  Created by Lennart Fischer on 24.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import MapKit

struct Tracker: Codable {
    
    var id: Int? = nil
    var name: String
    var deviceID: String? = nil
    var description: String? = nil
    var isEnabled: Bool = false
    var type: String? = nil
    var createdAt: Date? = nil
    var updatedAt: Date? = nil
    
    var trackingPoints: [TrackingPoint]
    
    var lastCoordinate: CLLocationCoordinate2D? {
        return trackingPoints.last?.coordinate
    }
    
    init(name: String, deviceID: String, trackingPoints: [TrackingPoint]) {
        self.name = name
        self.deviceID = deviceID
        self.trackingPoints = trackingPoints
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try values.decode(String.self, forKey: .name)
        let deviceID = try values.decode(String.self, forKey: .deviceID)
        
        self.init(name: name, deviceID: deviceID, trackingPoints: [])
        
        self.id = try values.decode(Int?.self, forKey: .id)
        self.description = try values.decode(String?.self, forKey: .description)
        self.isEnabled = try values.decode(Bool.self, forKey: .isEnabled)
        self.type = try values.decode(String?.self, forKey: .type)
        self.createdAt = try values.decode(Date?.self, forKey: .createdAt)
        self.updatedAt = try values.decode(Date?.self, forKey: .updatedAt)
        
        if values.contains(.trackingPoints) {
            self.trackingPoints = try values.decode([TrackingPoint].self, forKey: .trackingPoints)
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(deviceID, forKey: .deviceID)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(type, forKey: .type)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(trackingPoints, forKey: .trackingPoints)
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case deviceID = "device_id"
        case name = "name"
        case description = "description"
        case isEnabled = "is_enabled"
        case type = "type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case trackingPoints = "tracking_points"
        
    }
    
}
