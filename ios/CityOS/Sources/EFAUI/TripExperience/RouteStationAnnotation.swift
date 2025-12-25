//
//  RouteStationAnnotation.swift
//  
//
//  Created by Lennart Fischer on 27.12.22.
//

import Foundation
import MapKit

public class RouteStationAnnotation: MKPointAnnotation {
    
    public init(name: String, coordinate: CLLocationCoordinate2D) {
        super.init()
        self.title = name
        self.coordinate = coordinate
    }
    
    
}
