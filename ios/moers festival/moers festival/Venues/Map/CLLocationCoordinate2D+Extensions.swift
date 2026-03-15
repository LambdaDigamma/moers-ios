//
//  CLLocationCoordinate2D+Extensions.swift
//  moers festival
//
//  Created by Lennart Fischer on 16.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude 
            && lhs.longitude == rhs.longitude
    }
    
}
