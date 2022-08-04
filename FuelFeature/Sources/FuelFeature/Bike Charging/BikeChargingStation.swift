//
//  BikeChargingStation.swift
//  MMAPI
//
//  Created by Lennart Fischer on 06.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Core
import Foundation
import MapKit
import Fuse

public class BikeChargingStation: NSObject, Location {
    
    @objc public dynamic var name: String
    public var location: CLLocation
    
    public var postcode: String
    public var street: String
    public var place: String
    public var openingHours: OpeningHours
    public var phone: URL?
    
    public init(
        name: String,
        location: CLLocation,
        postcode: String,
        place: String,
        street: String,
        openingHours: OpeningHours,
        phone: URL?
    ) {
        
        self.name = name
        self.location = location
        self.postcode = postcode
        self.street = street
        self.place = place
        self.openingHours = openingHours
        self.phone = phone
        
    }
    
    // MARK: - Location
    
    public var tags: [String] {
        return [localizedCategory]
    }
    
    public var distance: Measurement<UnitLength> = Measurement(value: 0, unit: UnitLength.meters)
    
    // MARK: - MKAnnotation
    
    public var coordinate: CLLocationCoordinate2D { return location.coordinate }
    public var title: String? { return self.name }
    public var subtitle: String? { return nil }
    
    // MARK: - Categorizable
    
    public var category: String { return "Bike Charging Station" }
    public var localizedCategory: String { return String.localized("BikeChargingStation") }
    
    public struct OpeningHours: Equatable {
        
        var monday: String
        var tuesday: String
        var wednesday: String
        var thursday: String
        var friday: String
        var saturday: String
        var sunday: String?
        var feastday: String
        
    }
    
    // MARK: - Fuse
    
    public var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }
    
}
