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
    
    private var viewModel: BaseMapViewModel
    
    public init(
        viewModel: BaseMapViewModel,
        region: Binding<MKCoordinateRegion> = .constant(CoreSettings.defaultRegion()),
        userTrackingMode: Binding<MKUserTrackingMode>? = nil
    ) {
        self.viewModel = viewModel
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
        view.tintColor = UIColor.systemBlue
        view.cameraZoomRange = CoreSettings.cameraZoomRange
        view.cameraBoundary = CoreSettings.cameraBoundary()
        
//        view.addAnnotation(GenericAnnotation(coordinate: CoreSettings.regionCenter))
        
        viewModel.registeredAnnotationViews.forEach { (viewType, reuseIdentifier) in
            view.register(viewType, forAnnotationViewWithReuseIdentifier: reuseIdentifier)
        }
        
        if let userTrackingMode = userTrackingMode {
            view.setUserTrackingMode(userTrackingMode.wrappedValue, animated: false)
        }
        
        return view
        
    }
    
    public func updateUIView(_ uiView: MKMapView, context: Context) {
        
        context.coordinator.parent = self
        uiView.mapType = context.environment.mapType
        uiView.showsUserLocation = context.environment.showsUserLocation
        
        if let userTrackingMode = userTrackingMode {
            uiView.setUserTrackingMode(
                userTrackingMode.wrappedValue,
                animated: !context.transaction.disablesAnimations
            )
        }
        
        let existingAnnotations = Set(uiView.annotations.compactMap { $0 as? GenericAnnotation })
        let newAnnotations = Set(viewModel.annotations)
        
        let annotationsToRemove = existingAnnotations.subtracting(newAnnotations)
        let annotationsToAdd = newAnnotations.subtracting(existingAnnotations)
        
        uiView.removeAnnotations(Array(annotationsToRemove))
        uiView.addAnnotations(Array(annotationsToAdd))
        
    }
    
    @MainActor
    public class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: BaseMap
        private var pendingRegion: MKCoordinateRegion?
        private var hasScheduledRegionUpdate = false
        
        init(_ map: BaseMap) {
            parent = map
        }
        
        public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            scheduleRegionUpdate(mapView.region)
        }

        private func scheduleRegionUpdate(_ region: MKCoordinateRegion) {
            pendingRegion = region

            guard !hasScheduledRegionUpdate else { return }

            hasScheduledRegionUpdate = true

            Task { @MainActor [weak self] in
                guard let self = self else {
                    return
                }

                defer {
                    self.hasScheduledRegionUpdate = false
                }

                guard let pendingRegion = self.pendingRegion else {
                    return
                }

                self.pendingRegion = nil

                guard !self.isRegion(
                    self.parent.region.wrappedValue,
                    approximatelyEqualTo: pendingRegion
                ) else {
                    return
                }

                self.parent.region.wrappedValue = pendingRegion
            }
        }

        private func isRegion(
            _ lhs: MKCoordinateRegion,
            approximatelyEqualTo rhs: MKCoordinateRegion
        ) -> Bool {
            let accuracy = 0.000_001

            return abs(lhs.center.latitude - rhs.center.latitude) < accuracy
                && abs(lhs.center.longitude - rhs.center.longitude) < accuracy
                && abs(lhs.span.latitudeDelta - rhs.span.latitudeDelta) < accuracy
                && abs(lhs.span.longitudeDelta - rhs.span.longitudeDelta) < accuracy
        }
        
        public func mapView(
            _ mapView: MKMapView,
            viewFor annotation: MKAnnotation
        ) -> MKAnnotationView? {
            
            return parent.viewModel.configureView(mapView, annotation)
            
        }
        
        public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            if let annotation = view.annotation as? GenericAnnotation {
                parent.viewModel.onAnnotationSelected?(annotation)
            }
            
        }
        
    }
    
}

struct BaseMap_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewModel = BaseMapViewModel(annotations: [
            
        ])
        
        BaseMap(viewModel: viewModel)
            .ignoresSafeArea(.container, edges: .all)
            .preferredColorScheme(.dark)
    }
    
}
