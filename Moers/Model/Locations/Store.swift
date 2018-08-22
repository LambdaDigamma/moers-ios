//
//  Store.swift
//  Moers
//
//  Created by Lennart Fischer on 17.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import MapKit

class Store: NSObject, Codable, MKAnnotation, Location {
    
    public let id: Int
    public var name: String
    public let branch: String
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
    
    var location: CLLocation { return CLLocation(latitude: lat, longitude: lng) }
    
    var title: String? { return self.name }
    
    var subtitle: String? { return self.street + " " + self.houseNumber }
    
    var detailSubtitle: String { return branch }
    
    lazy var detailImage: UIImage = { Store.image(from: branch) }()
    
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
