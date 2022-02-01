//
//  BaseMap.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import Foundation
import SwiftUI
import MapKit

public struct BaseMap: UIViewRepresentable {
    
    public typealias UIViewType = MKMapView
    
    private var region: Binding<MKCoordinateRegion>
    private var userTrackingMode: Binding<MKUserTrackingMode>?
    
    public init(
        region: Binding<MKCoordinateRegion> = .constant(CoreSettings.defaultRegion()),
        userTrackingMode: Binding<MKUserTrackingMode>? = nil
    ) {
        self.region = region
        self.userTrackingMode = userTrackingMode
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> MKMapView {
        
        let view = MKMapView(frame: .zero)
        
        view.delegate = context.coordinator
        view.mapType = context.environment.mapType
        view.setRegion(region.wrappedValue, animated: false)
        view.showsUserLocation = context.environment.showsUserLocation
        
        view.addAnnotation(GenericAnnotation(coordinate: CoreSettings.regionCenter))
        
        if let userTrackingMode = userTrackingMode {
            view.setUserTrackingMode(userTrackingMode.wrappedValue, animated: false)
        }
        
        return view
        
    }
    
    public func updateUIView(_ uiView: MKMapView, context: Context) {
        
        uiView.mapType = context.environment.mapType
        uiView.showsUserLocation = context.environment.showsUserLocation
        
        if let userTrackingMode = userTrackingMode {
            uiView.setUserTrackingMode(
                userTrackingMode.wrappedValue,
                animated: !context.transaction.disablesAnimations
            )
        }
        
    }
    
    public class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: BaseMap
        
        init(_ map: BaseMap) {
            parent = map
        }
        
        public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            self.parent.region.wrappedValue = mapView.region
        }
        
        public func mapView(
            _ mapView: MKMapView,
            viewFor annotation: MKAnnotation
        ) -> MKAnnotationView? {
            
            if annotation is MKUserLocation {
                return nil
            }
            
            mapView.dequeueReusableAnnotationView(withIdentifier: "reuse", for: annotation)
            
            let view = GenericAnnotationView(annotation: annotation, reuseIdentifier: "reuse")
            
            return view
        }
        
    }
    
}

struct BaseMap_Previews: PreviewProvider {
    
    static var previews: some View {
        
        BaseMap()
            .ignoresSafeArea(.container, edges: .all)
            .preferredColorScheme(.dark)
    }
    
}
