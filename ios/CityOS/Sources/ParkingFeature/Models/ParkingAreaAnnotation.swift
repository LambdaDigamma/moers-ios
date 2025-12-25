//
//  ParkingAreaAnnotation.swift
//  
//
//  Created by Lennart Fischer on 01.02.22.
//

import Foundation
import MapKit
import Core

public class ParkingAreaAnnotation: GenericAnnotation, InteractsWithAnnotationView {
    
    public typealias AnnotationView = ParkingAreaAnnotationView
    
    public func update(_ view: ParkingAreaAnnotationView) {
        
    }
    
    public static var reuseIdentifier: String = "parking_area_annotation_view"
    
//    public override func annotationView() -> MKAnnotationView.Type {
//        return ParkingAreaAnnotationView.self
//    }
    
}
