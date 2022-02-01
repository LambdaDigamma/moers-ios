//
//  GenericAnnotation.swift
//  
//
//  Created by Lennart Fischer on 31.01.22.
//

import Foundation
import MapKit

public protocol CanGenerateAnnotation {
    
    associatedtype Annotation = MKAnnotation
    
    func annotation() -> Annotation
    
}

public class GenericAnnotation: NSObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}
