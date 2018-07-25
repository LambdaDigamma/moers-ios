//
//  PetrolStation.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import CoreLocation

struct PetrolStation: Codable {
    
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

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
}
