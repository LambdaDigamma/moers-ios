//
//  ToiletAnnotation.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import Foundation
import MapKit

public class ToiletAnnotation: NSObject, MKAnnotation, DisplayCacheableAnnotation, ScaleDependentAnnotation {
    
    public var title: String?
    public var coordinate: CLLocationCoordinate2D
    
    public init(
        title: String? = nil,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.coordinate = coordinate
    }
    
    public static let mapScaleThreshold: Double = 0.005
    
    public static let displayCacheKey = String(describing: ToiletAnnotation.self)
    
}
