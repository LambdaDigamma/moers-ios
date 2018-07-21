//
//  Location.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import CoreLocation

protocol Location {
    
    var location: CLLocation { get }
    var name: String { get }
    
}

