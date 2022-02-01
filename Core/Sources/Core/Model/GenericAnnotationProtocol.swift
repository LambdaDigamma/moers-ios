//
//  GenericAnnotation.swift
//  
//
//  Created by Lennart Fischer on 01.02.22.
//

import Foundation
import MapKit

//public protocol GenericAnnotation: MKAnnotation {
//
//    associatedtype AnnotationView = MKAnnotationView
//
//    func update(_ view: AnnotationView)
//
//}

public protocol InteractsWithAnnotationView {
    
    static var reuseIdentifier: String { get }
    
}

open class GenericAnnotation: NSObject, MKAnnotation {
    
    public typealias AnnotationView = MKAnnotationView
    
    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    
    public init(
        coordinate: CLLocationCoordinate2D,
        title: String
    ) {
        self.coordinate = coordinate
        self.title = title
    }
    
    public func update(_ view: MKAnnotationView) {
        
    }
    
//    open func annotationView() -> MKAnnotationView.Type {
//        return MKAnnotationView.self
//    }
    
}
