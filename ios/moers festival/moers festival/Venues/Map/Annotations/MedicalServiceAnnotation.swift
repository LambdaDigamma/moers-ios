//
//  MedicalServiceAnnotation.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import Foundation
import MapKit

public class MedicalServiceAnnotation: NSObject, MKAnnotation, DisplayCacheableAnnotation, ScaleDependentAnnotation {
    
    public var title: String?
    public var coordinate: CLLocationCoordinate2D
    
    public init(
        title: String? = "Sanitätsdienst",
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.coordinate = coordinate
    }
    
    public static let mapScaleThreshold: Double = 0.005
    
    public static let displayCacheKey = String(describing: MedicalServiceAnnotation.self)
    
}
