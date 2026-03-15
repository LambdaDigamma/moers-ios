//
//  OverlayRendererPreviewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import UIKit
import MapKit
import SwiftUI

extension UIViewController {
    
    private struct Preview: UIViewControllerRepresentable {
        
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    public var preview: some View {
        return Preview(viewController: self)
    }
}


public class OverlayRendererPreviewController<MultiPolygonRenderer: MKMultiPolygonRenderer>: UIViewController, MKMapViewDelegate {
    
    lazy var map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
//    private let multiPolygonRenderer: MultiPolygonRenderer
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addDataAndCenter()
    }
    
    private func setupUI() {
        
        self.view.addSubview(map)
        self.map.delegate = self
        
        let constraints = [
            map.topAnchor.constraint(equalTo: self.view.topAnchor),
            map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func addDataAndCenter() {
        
        let points = [
            [6.616433294776047, 51.44255640987149],
            [6.616370896493862, 51.44240105007732],
            [6.616264892770658, 51.44241684302442],
            [6.616328255307232, 51.4425723638073],
            [6.616433294776047, 51.44255640987149]
        ].map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0] )}
        
        let multiPolygon = MKMultiPolygon([MKPolygon(coordinates: points, count: points.count)])
        
        map.addOverlay(multiPolygon)
        
        map.setRegion(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 51.44241684302442,
                longitude: 6.616264892770658
            ),
            latitudinalMeters: 50,
            longitudinalMeters: 50),
                      animated: false
        )
        
    }
    
    // MARK: - Map Delegate -
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let overlay = overlay as? MKMultiPolygon {
            
            let renderer = MultiPolygonRenderer(multiPolygon: overlay)
            
            return renderer
            
        }
        
        return MKOverlayRenderer(overlay: overlay)
        
    }
    
}
