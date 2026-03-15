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

public class AnnotationPreviewController<AnnotationView: MKAnnotationView>: UIViewController, MKMapViewDelegate {
    
    lazy var map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var annotationProducer: ((CLLocationCoordinate2D) -> MKAnnotation)?
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.addDataAndCenter()
    }
    
    // MARK: - UI -
    
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
        
        let point = CLLocationCoordinate2D(latitude: 51.44255640987149, longitude: 6.616433294776047)
        
        guard let annotation = annotationProducer?(point) else { return }
        
        self.map.addAnnotation(annotation)
        
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
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        return AnnotationView(annotation: annotation, reuseIdentifier: "reuse")
        
    }
    
}
