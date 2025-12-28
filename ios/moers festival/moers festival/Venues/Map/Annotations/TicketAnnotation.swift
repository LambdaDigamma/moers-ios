//
//  TicketAnnotation.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Core
import Foundation
import MapKit

public class TicketAnnotation: NSObject, MKAnnotation, DisplayCacheableAnnotation, ScaleDependentAnnotation {
    
    public var title: String?
    public var coordinate: CLLocationCoordinate2D
    
    public init(
        title: String? = nil,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.coordinate = coordinate
    }
    
    public static let mapScaleThreshold: Double = 0.01
    
    public static let displayCacheKey = String(describing: TicketAnnotation.self)
    
}
