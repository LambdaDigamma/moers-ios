//
//  BikeChargingStation.swift
//  Moers
//
//  Created by Lennart Fischer on 11.11.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation
import MapKit

class BikeChargingStation: NSObject, Location, MKAnnotation {
    
    var name: String
    var location: CLLocation
    
    var postcode: String
    var street: String
    var place: String
    var openingHours: OpeningHours
    var phone: URL?
    
    struct OpeningHours {
        
        var monday: String
        var tuesday: String
        var wednesday: String
        var thursday: String
        var friday: String
        var saturday: String
        var sunday: String
        var feastday: String
        
    }
    
    init(name: String, location: CLLocation, postcode: String, place: String, street: String, openingHours: OpeningHours, phone: URL?) {
        
        self.name = name
        self.location = location
        self.postcode = postcode
        self.street = street
        self.place = place
        self.openingHours = openingHours
        self.phone = phone
        
    }
    
    var title: String? {
        
        return self.name
        
    }
    
    var subtitle: String? {
        
        return nil
        
    }
    
    var coordinate: CLLocationCoordinate2D {
        
        return location.coordinate
        
    }
    
}
