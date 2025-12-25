//
//  TransitStationAnnotation.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import MapKit

public enum TransitStationType {
    
    case trainStation
    case busStation
    
    var imageName: String {
        switch self {
            case .trainStation:
                return "tram.fill"
            case .busStation:
                return "bus.fill"
        }
    }
    
}

public class TransitStationAnnotation: NSObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var subtitle: String?
    public var transitStationType: TransitStationType
    
    public init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.transitStationType = .trainStation
    }
    
    public convenience init(coordinate: CLLocationCoordinate2D, title: String, type: TransitStationType) {
        self.init(coordinate: coordinate, title: title, subtitle: nil)
        self.transitStationType = type
    }
    
}
