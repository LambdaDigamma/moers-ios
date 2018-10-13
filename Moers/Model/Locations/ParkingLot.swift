//
//  ParkingLot.swift
//  Moers
//
//  Created by Lennart Fischer on 17.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

enum Status: String, Localizable {
    
    case unchanged = "unverändert"
    case descends = "fallend"
    case ascends = "aufsteigend"
    case undocumented = "nicht erfasst"
    
    static func localizedForCase(_ c: Status) -> String {
        
        switch c {
        case .ascends: return String.localized("ParkingLotAscends")
        case .descends: return String.localized("ParkingLotDescends")
        case .unchanged: return String.localized("ParkingLotUnchanged")
        case .undocumented: return String.localized("ParkingLotUndocumented")
        }
        
    }
    
}

class ParkingLot: NSObject, Location {
    
    @objc dynamic public var name: String
    
    public var address: String
    public var slots: Int
    public var free: Int
    public var status = Status.undocumented
    
    init(name: String, address: String, slots: Int, free: Int, status: Status, location: CLLocation) {
        
        self.location = location
        self.name = name
        
        self.address = address
        self.slots = slots
        self.free = free
        self.status = status
        
    }
    
    // MARK: - Search
    
    public var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }
    
    // MARK: - Location
    
    public var location: CLLocation
    
    lazy var distance: Double = {
        if let location = LocationManager.shared.lastLocation {
            return location.distance(from: self.location)
        } else {
            return 0
        }
    }()
    
    public var tags: [String] {
        return [localizedCategory, "Parken"]
    }
    
    // MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D { return location.coordinate }
    var title: String? { return self.name }
    var subtitle: String? { return address }
    
    // MARK: - Categorizable
 
    var category: String { return "Parking Lot" }
    var localizedCategory: String { return String.localized("ParkingLot") }
    
    // MARK: - DetailRepresentable
    
    var detailSubtitle: String {
        
        if LocationManager.shared.authorizationStatus == .authorizedAlways ||
            LocationManager.shared.authorizationStatus == .authorizedWhenInUse {
            
            let dist = prettifyDistance(distance: distance)
            
            return "\(dist) • \(localizedCategory)"
            
        } else {
            return localizedCategory
        }
        
    }
    
    var detailHeight: CGFloat { return 220.0 }
    lazy var detailImage: UIImage = { return #imageLiteral(resourceName: "parkingLot") }()
    lazy var detailViewController: UIViewController = { DetailParkingViewController() }()
    
}
