//
//  BikeChargingStation.swift
//  Moers
//
//  Created by Lennart Fischer on 11.11.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation
import MapKit
import Fuse
import MMAPI

class BikeChargingStation: NSObject, Location {

    @objc dynamic var name: String
    var location: CLLocation

    var postcode: String
    var street: String
    var place: String
    var openingHours: OpeningHours
    var phone: URL?

    init(name: String, location: CLLocation, postcode: String, place: String, street: String, openingHours: OpeningHours, phone: URL?) {

        self.name = name
        self.location = location
        self.postcode = postcode
        self.street = street
        self.place = place
        self.openingHours = openingHours
        self.phone = phone

    }
    
    var tags: [String] {
        return [localizedCategory]
    }

    lazy var distance: Double = {
        if let location = LocationManager.shared.lastLocation {
            return location.distance(from: self.location)
        } else {
            return 0
        }
    }()

    var title: String? { return self.name }

    var subtitle: String? { return nil }

    var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }

    var coordinate: CLLocationCoordinate2D { return location.coordinate }

    var detailSubtitle: String { return localizedCategory }

    lazy var detailImage: UIImage = { #imageLiteral(resourceName: "ebike") }()

    lazy var detailViewController: UIViewController = { UIViewController() }()

    var detailHeight: CGFloat = 520.0

    var category: String { return "Bike Charging Station" }

    var localizedCategory: String { return String.localized("BikeChargingStation") }

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
    
}
