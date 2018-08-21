//
//  PetrolStation.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import MapKit

class PetrolStation: NSObject, Location, Codable, MKAnnotation {
    
    var id: String
    var name: String
    var brand: String
    var street: String
    var place: String
    var houseNumber: String?
    var postCode: Int?
    var lat: Double
    var lng: Double
    var dist: Double?
    var diesel: Double? = nil
    var e5: Double? = nil
    var e10: Double? = nil
    var price: Double? = nil
    var isOpen: Bool
    var wholeDay: Bool? = nil
    var openingTimes: [PetrolStationTimeEntry]? = nil
    var overrides: [String]? = nil
    var state: String? = nil
    
    init(id: String, name: String, brand: String, street: String, place: String, houseNumber: String?, postCode: Int?, lat: Double, lng: Double,
    dist: Double?, diesel: Double?, e5: Double?, e10: Double?, price: Double?,
    isOpen: Bool, wholeDay: Bool?, openingTimes: [PetrolStationTimeEntry]?, overrides: [String]?, state: String?) {
        
        self.id = id
        self.name = name
        self.brand = brand
        self.street = street
        self.place = place
        self.houseNumber = houseNumber
        self.postCode = postCode
        self.lat = lat
        self.lng = lng
        self.dist = dist
        self.diesel = diesel
        self.e5 = e5
        self.e10 = e10
        self.price = price
        self.isOpen = isOpen
        self.wholeDay = wholeDay
        self.openingTimes = openingTimes
        self.overrides = overrides
        self.state = state

    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    var location: CLLocation {
        return CLLocation(latitude: self.lat, longitude: self.lng)
    }
    
    var title: String? {
        return self.name
    }
    
    var subtitle: String? {
        return self.brand
    }
    
}
