//
//  Mappable.swift
//  moers festival
//
//  Created by Lennart Fischer on 31.05.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Core
import Foundation
import CoreLocation

protocol Mappable {
    
    var coordinate: CLLocationCoordinate2D { get }
    
}

extension Tracker: Mappable {
    
    var coordinate: CLLocationCoordinate2D {
        return lastCoordinate ?? CLLocationCoordinate2D(latitude: 51.4397, longitude: 6.6190)
    }
    
}

extension Entry: Mappable {
    
    
    
}
