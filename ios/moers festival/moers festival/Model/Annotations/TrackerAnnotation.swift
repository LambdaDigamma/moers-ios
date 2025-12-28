//
//  TrackerAnnotation.swift
//  moers festival
//
//  Created by Lennart Fischer on 24.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Core
import MapKit

class TrackerAnnotation: NSObject, MKAnnotation {
    
    var tracker: Tracker
    var coordinate: CLLocationCoordinate2D {
        return tracker.lastCoordinate ?? CLLocationCoordinate2D()
    }
    
    init(tracker: Tracker) {
        self.tracker = tracker
        super.init()
    }
    
    var title: String? { return tracker.name }
    
}
