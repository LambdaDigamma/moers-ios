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

class ParkingLot: NSObject, Location, MKAnnotation {
    
    var location: CLLocation
    var name: String
    
    var address: String
    var slots: Int
    var free: Int
    var status = Status.undocumented
    
    init(name: String, address: String, slots: Int, free: Int, status: Status, location: CLLocation) {
        
        self.location = location
        self.name = name
        
        self.address = address
        self.slots = slots
        self.free = free
        self.status = status
        
    }
    
    var title: String? { return self.name }
    
    var subtitle: String? { return address }
    
    var coordinate: CLLocationCoordinate2D { return location.coordinate }
    
    var detailSubtitle: String { return localizedCategory }
    
    var detailHeight: CGFloat { return 220.0 }
    
    var category: String { return "Parking Lot" }
    
    var localizedCategory: String { return String.localized("ParkingLot") }
    
}
