//
//  GenericAnnotation.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.06.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

import MapKit

class GenericAnnotation: NSObject, MKAnnotation {
    
    var marker: GenericMarker
    var coordinate: CLLocationCoordinate2D {
        return marker.coordinate
    }
    
    init(marker: GenericMarker) {
        self.marker = marker
        super.init()
    }
    
    var title: String? { return marker.title }
    var subtitle: String? { return marker.subtitle }
    
}
