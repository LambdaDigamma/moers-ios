//
//  Restaurant.swift
//  Moers
//
//  Created by Lennart Fischer on 03.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import MapKit

class Restaurant: NSObject, Codable, Location {
    
    public let id: Int
    @objc dynamic public var name: String
    public let cuisine: String
    public let street: String
    public let houseNumber: String
    public let postcode: String
    public let place: String
    public let url: String?
    public let phone: String?
    public let monday: String?
    public let tuesday: String?
    public let wednesday: String?
    public let thursday: String?
    public let friday: String?
    public let saturday: String?
    public let sunday: String?
    public let other: String?
    private let lat: Double
    private let lng: Double
    
    init(id: Int, name: String, cuisine: String, street: String, houseNumber: String, postcode: String, place: String, url: String?, phone: String?, monday: String?, tuesday: String?, wednesday: String?, thursday: String?, friday: String?, saturday: String?, sunday: String?, other: String?, lat: Double, lng: Double) {
        
        self.id = id
        self.name = name
        self.cuisine = cuisine
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
    
    var location: CLLocation { return CLLocation(latitude: lat, longitude: lng) }
    
    var title: String? { return self.name }
    
    var subtitle: String? { return self.street + " " + self.houseNumber }
    
    var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }
    
    var detailSubtitle: String { return cuisine }
    
    lazy var detailImage: UIImage = { UIImage() }()
    
    lazy var detailViewController: UIViewController = { DetailShopViewController.fromStoryboard() }()
    
    var detailHeight: CGFloat { return 550.0 }
    
    var category: String { return "Shop" }
    
    var localizedCategory: String { return String.localized("Shop") }
    
    public var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: lat, longitude: lng) }
    
    public static func image(from branch: String) -> UIImage {
        
        guard let image = ShopIconDrawer.annotationImage(from: branch) else { return UIImage() }
        guard let resizedImage = UIImage.imageResize(imageObj: image, size: CGSize(width: 64, height: 64), scaleFactor: 0.75) else { return UIImage() }
        
        return resizedImage
        
    }
    
}


