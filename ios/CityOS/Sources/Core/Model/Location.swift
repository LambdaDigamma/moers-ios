//
//  Location.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import MapKit
import Fuse

public protocol Location: Categorizable, Fuseable, MKAnnotation {
    
    var location: CLLocation { get }
    var name: String { get }
    var tags: [String] { get }
    var distance: Measurement<UnitLength> { get set }
    
}
