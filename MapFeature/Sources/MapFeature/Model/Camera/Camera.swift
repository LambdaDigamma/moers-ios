//
//  Camera.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import MapKit
import Fuse
import MMAPI

public typealias PanoID = Int

public final class Camera: NSObject, Location, Codable, Identifiable {
    
    public var id: PanoID
    @objc public dynamic var name: String
    public var location: CLLocation
    
    public init(name: String, location: CLLocation, panoID: PanoID) {
        
        self.name = name
        self.location = location
        self.id = panoID
        
    }
    
    public required convenience init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try values.decode(String.self, forKey: .name)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        let panoID = try values.decode(Int.self, forKey: .panoID)
        
        self.init(
            name: name,
            location: CLLocation(latitude: latitude, longitude: longitude),
            panoID: panoID
        )
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(id, forKey: .panoID)
        
    }
    
    // MARK: - Location
    
    public var distance: Measurement<UnitLength> = Measurement(value: 0, unit: UnitLength.meters)
    
    public var tags: [String] {
        return [localizedCategory]
    }
    
    // MARK: - MKAnnotation
    
    public var coordinate: CLLocationCoordinate2D { return location.coordinate }
    public var title: String? { return self.name }
    public var subtitle: String? { return nil }
    
    // MARK: - Categorizable
    
    public var category: String { return "Camera" }
    public var localizedCategory: String { return String.localized("Camera") }
    
    // MARK: - Fuse
    
    public var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        
        case name = "name"
        case latitude = "lat"
        case longitude = "lng"
        case panoID = "panoID"
        
    }
    
}

extension Camera: Stubbable {
    
    public static func stub(withID id: Int) -> Camera {
        
        return Camera(name: "Test Camera",
                      location: CLLocation(),
                      panoID: id)
        
    }
    
}
