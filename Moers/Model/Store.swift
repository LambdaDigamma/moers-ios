//
//  Store.swift
//  Moers
//
//  Created by Lennart Fischer on 17.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import MapKit

class Store: NSObject, Codable, MKAnnotation {
    
    public let id: Int
    public var name: String
    public let branch: String
    public let street: String
    public let houseNumber: String
    public let postcode: String
    public let place: String
    public let url: String?
    public let phone: String?
    private let monday: String?
    private let tuesday: String?
    private let wednesday: String?
    private let thursday: String?
    private let friday: String?
    private let saturday: String?
    private let sunday: String?
    private let other: String?
    private let lat: Double
    private let lng: Double
    
    init(id: Int, name: String, branch: String, street: String, houseNumber: String, postcode: String, place: String, url: String?, phone: String?, monday: String?, tuesday: String?, wednesday: String?, thursday: String?, friday: String?, saturday: String?, sunday: String?, other: String?, lat: Double, lng: Double) {
        
        self.id = id
        self.name = name
        self.branch = branch
        self.street = street
        self.houseNumber = houseNumber
        self.postcode = postcode
        self.place = place
        self.url = url
        self.phone = phone
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.other = other
        self.lat = lat
        self.lng = lng
        
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
}

extension Store: Location {
    
    var location: CLLocation {
        return CLLocation(latitude: lat, longitude: lng)
    }
    
    var title: String? {
        return self.name
    }
    
    var subtitle: String? {
        return self.street + " " + self.houseNumber
    }
    
}
