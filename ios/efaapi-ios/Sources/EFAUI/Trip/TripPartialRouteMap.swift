//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 16.12.22.
//

import SwiftUI
import MapKit
import EFAAPI

public let routeStationAnnotationIdentifier = "routeStationAnnotation"

public struct TripPartialRouteMap: UIViewRepresentable {
    
    public typealias UIViewType = MKMapView
    
    @ObservedObject var viewModel: InTrainMapViewModel
    
    public func makeUIView(
        context: UIViewRepresentableContext<TripPartialRouteMap>
    ) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.tintColor = UIColor(Color.routeLine)
        mapView.showsCompass = false
        mapView.register(RouteStationAnnotationView.self, forAnnotationViewWithReuseIdentifier: routeStationAnnotationIdentifier)
        return mapView
    }
    
    public func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<TripPartialRouteMap>) {
        
//        uiView.userTrackingMode = .followWithHeading
        uiView.showsUserLocation = true
        
        if let polyline = viewModel.polyline.value {
            uiView.removeOverlays(uiView.overlays)
            uiView.addOverlays(polyline, level: .aboveLabels)
        }
        
        if let points = viewModel.points.value {
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(points)
        }
        
    }
    
    public func makeCoordinator() -> TripPartialRouteMap.Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator -
    
    public final class Coordinator: NSObject, MKMapViewDelegate {
        
        private let mapView: TripPartialRouteMap
        
        public init(_ mapView: TripPartialRouteMap) {
            self.mapView = mapView
        }
        
        public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            if (overlay is MKPolyline) {
                let pr = MKPolylineRenderer(overlay: overlay)
                pr.strokeColor = UIColor(Color.routeLine)
                pr.lineWidth = 5
                return pr
            }
          
            return MKOverlayRenderer()
        }
        
        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            guard let annotation = annotation as? RouteStationAnnotation else {
                return nil
            }
            
            var view: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(
                withIdentifier: routeStationAnnotationIdentifier
            ) as? RouteStationAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = RouteStationAnnotationView(annotation: annotation, reuseIdentifier: routeStationAnnotationIdentifier)
                view.annotation = annotation
            }
            
            return view
            
        }
        
    }
    
}

//struct TripPartialRouteMap_Previews: PreviewProvider {
//    static var previews: some View {
//        TripPartialRouteMap(
//            center: .constant(.init(latitude: 40.0, longitude: 50.2)),
//            line: "ddb:90E33: :R:j23"
//        )
//    }
//}
