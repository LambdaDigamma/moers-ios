//
//  BaseMapViewModel.swift
//  
//
//  Created by Lennart Fischer on 31.01.22.
//

import Foundation
import MapKit
import Observation

@Observable
public class BaseMapViewModel: StandardViewModel {
    
    public var annotations: [GenericAnnotation]
    public var registeredAnnotationViews: [(MKAnnotationView.Type, String)] = []
    
    public var configureView: (_ mapView: MKMapView, _ annotation: MKAnnotation) -> MKAnnotationView?
    public var onAnnotationSelected: ((GenericAnnotation) -> Void)?
    
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

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
