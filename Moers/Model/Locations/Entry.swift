//
//  Entry.swift
//  Moers
//
//  Created by Lennart Fischer on 06.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

class Entry: NSObject, Codable, Location {
    
    public var id: Int
    @objc dynamic public var name: String
    public var tags: [String]
    public var street: String
    public var houseNumber: String
    public var postcode: String
    public var place: String
    public var url: String?
    public var phone: String?
    public var monday: String?
    public var tuesday: String?
    public var wednesday: String?
    public var thursday: String?
    public var friday: String?
    public var saturday: String?
    public var sunday: String?
    public var other: String?
    public let createdAt: String?
    public var updatedAt: String?
    private let lat: Double
    private let lng: Double
    
    public var isValidated: Bool

    init(id: Int, name: String, tags: [String], street: String, houseNumber: String, postcode: String, place: String, url: String?, phone: String?, monday: String?, tuesday: String?, wednesday: String?, thursday: String?, friday: String?, saturday: String?, sunday: String?, other: String?, lat: Double, lng: Double, isValidated: Bool, createdAt: String?, updatedAt: String?) {

        self.id = id
        self.name = name
        self.tags = tags
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
        self.isValidated = isValidated
        self.createdAt = createdAt
        self.updatedAt = updatedAt

    }
    
    var updateDate: Date? {
        return Date.from(updatedAt ?? "", withFormat: "yyyy-MM-dd HH:mm:ss")
    }
    
    var creationDate: Date? {
        return Date.from(createdAt ?? "", withFormat: "yyyy-MM-dd HH:mm:ss")
    }
    
    // MARK: - Search
    
    var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }
    
    // MARK: - Location
    
    var location: CLLocation { return CLLocation(latitude: lat, longitude: lng) }
    
    lazy var distance: Double = {
        if let location = LocationManager.shared.lastLocation {
            return location.distance(from: self.location)
        } else {
            return 0
        }
    }()
    
    // MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: lat, longitude: lng) }
    var title: String? { return self.name }
    var subtitle: String? { return self.street + " " + self.houseNumber }
    
    // MARK: - Categorizable
    
    var category: String { return "Entry" }
    var localizedCategory: String { return "Eintrag" } // TODO: Localize this
    
    // MARK: - DetailRepresentable
    
    var detailSubtitle: String {
        
        if LocationManager.shared.authorizationStatus == .authorizedAlways ||
            LocationManager.shared.authorizationStatus == .authorizedWhenInUse {
            
            let dist = prettifyDistance(distance: distance)
            
            return "\(dist) • \(street) \(houseNumber)"
            
        } else {
            return self.street + " " + self.houseNumber
        }
        
    }
    
    var detailHeight: CGFloat { return 750.0 }
    lazy var detailImage: UIImage = { return #imageLiteral(resourceName: "entry") }()
    lazy var detailViewController: UIViewController = { DetailEntryViewController.fromStoryboard() }()
    
}
