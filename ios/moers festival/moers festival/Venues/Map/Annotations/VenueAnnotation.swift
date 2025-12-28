//
//  VenueAnnotation.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

#if canImport(CoreLocation)

import MapKit
import CoreLocation
import MMEvents

public class VenueAnnotation: NSObject, MKAnnotation, DisplayCacheableAnnotation {
    
    public var title: String?
    public var coordinate: CLLocationCoordinate2D
    public var placeID: Place.ID
    
    public init(
        title: String? = nil,
        coordinate: CLLocationCoordinate2D,
        placeID: Place.ID
    ) {
        self.title = title
        self.coordinate = coordinate
        self.placeID = placeID
    }
    
    public static let mapScaleThreshold: Double = 0.01
    
    public static let displayCacheKey = String(describing: VenueAnnotation.self)
    
}

#endif
