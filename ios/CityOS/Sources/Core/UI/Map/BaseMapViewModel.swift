//
//  BaseMapViewModel.swift
//  
//
//  Created by Lennart Fischer on 31.01.22.
//

import Foundation
import MapKit

public class BaseMapViewModel: StandardViewModel {
    
    @Published public var annotations: [GenericAnnotation]
    @Published public var registeredAnnotationViews: [(MKAnnotationView.Type, String)] = []
    
    public var configureView: (_ mapView: MKMapView, _ annotation: MKAnnotation) -> MKAnnotationView?
    
    public init(annotations: [GenericAnnotation] = []) {
        self.annotations = annotations
        self.configureView = { (_: MKMapView, _: MKAnnotation) in
            return nil
        }
    }
    
    public func register(view: MKAnnotationView.Type, reuseIdentifier: String) {
        self.registeredAnnotationViews.append((view, reuseIdentifier))
    }
    
    public func annotationViewsToRegister() -> [MKAnnotationView.Type] {
        return self.annotations.map({
            let viewType = type(of: $0).AnnotationView
            return viewType
//            return (viewType, viewType.)
        })
    }
    
}
