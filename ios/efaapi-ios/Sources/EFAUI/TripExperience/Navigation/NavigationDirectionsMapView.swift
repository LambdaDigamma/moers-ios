//
//  NavigationDirectionsView.swift
//  
//
//  Created by Lennart Fischer on 25.12.22.
//

import UIKit
import SwiftUI
import MapKit
import Core

public struct NavigationDirectionsMapView: UIViewRepresentable {
    
    public typealias UIViewType = MKMapView
    
    @ObservedObject public var viewModel: NavigationViewModel
    
    public init(viewModel: NavigationViewModel) {
        self.viewModel = viewModel
    }
    
    public func makeUIView(
        context: UIViewRepresentableContext<NavigationDirectionsMapView>
    ) -> MKMapView {
        
        let mapView = MKMapView()
        mapView.tintColor = UIColor(Color.routeLine)
        mapView.delegate = context.coordinator
        mapView.register(TransitStationAnnotationView.self, forAnnotationViewWithReuseIdentifier: Coordinator.annotationIdentifier)
        
        Task {
            await viewModel.load()
            self.addDirection(mapView: mapView)
        }
        
        return mapView
    }
    
    public func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<NavigationDirectionsMapView>) {
        
        uiView.userTrackingMode = .followWithHeading
        uiView.showsUserLocation = true
        
    }
    
    public func makeCoordinator() -> NavigationDirectionsMapView.Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Annotations -
    
    private func addDirection(mapView: MKMapView) {
        
        guard let directions = viewModel.directions.value else { return }
        
        if let firstRoute = directions.routes.first {
            
            let region = MKCoordinateRegion(
                center: firstRoute.polyline.coordinate,
                latitudinalMeters: 150,
                longitudinalMeters: 150
            )
            
            mapView.setRegion(region, animated: true)
            mapView.addOverlay(firstRoute.polyline)
        }
        
        let destination = directions.destination.placemark.coordinate
        let annotation = TransitStationAnnotation(coordinate: destination, title: "Moers Bahnhof", type: .trainStation)
        
        mapView.addAnnotation(annotation)
        
    }
    
    // MARK: - Coordinator -
    
    public final class Coordinator: NSObject, MKMapViewDelegate {
        
        private let mapView: NavigationDirectionsMapView
        internal static let annotationIdentifier = "transitStationAnnotation"
        
        public init(_ mapView: NavigationDirectionsMapView) {
            
            self.mapView = mapView
            
        }
        
        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            guard let annotation = annotation as? TransitStationAnnotation else {
                return nil
            }
            
            var view: MKMarkerAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: Self.annotationIdentifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = TransitStationAnnotationView(annotation: annotation, reuseIdentifier: Self.annotationIdentifier)
                view.annotation = annotation
            }
            
            return view
            
        }
        
        public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            if (overlay is MKPolyline) {
                let pr = MKPolylineRenderer(overlay: overlay)
                pr.strokeColor = UIColor(Color.routeLine)
                pr.lineWidth = 7
                return pr
            }
            
            return MKOverlayRenderer()
        }
        
    }
    
}
