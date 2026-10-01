//
//  ParkMapOverlay.swift
//  moers festival
//
//  Created by Lennart Fischer on 29.01.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import MapKit

class ParkMapOverlay: NSObject, MKOverlay {
    
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(park: Festivalhalle) {
        boundingMapRect = park.overlayBoundingMapRect
        coordinate = park.midCoordinate
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
