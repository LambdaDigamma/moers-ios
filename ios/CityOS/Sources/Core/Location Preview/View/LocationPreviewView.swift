//
//  LocationPreviewView.swift
//  MMUI
//
//  Created by Lennart Fischer on 26.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import UIKit
import MapKit
import Combine

public class LocationPreviewView: UIView, MKMapViewDelegate {
    
    // MARK: - Properties
    
    private let viewModel: LocationPreviewViewModel
    
    public init(viewModel: LocationPreviewViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.bindData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var annotationTask: Task<Void, Never>?
    
    // MARK: - UI
    
    private lazy var map = { CoreViewFactory.map() }()
    private lazy var locationInformation = { CoreViewFactory.locationInformation() }()
    
    public private(set) var coordinate: CLLocationCoordinate2D?
    
    public var startNavigation: AnyPublisher<Void, Never> {
        return locationInformation.startNavigation.eraseToAnyPublisher()
    }
    
    private func setupUI() {
        
        self.addSubview(map)
        self.addSubview(locationInformation)
        
    }
    
    private func setupConstraints() {
        
        let margins = self.readableContentGuide
        
        let mapConstraints = [
            map.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
    
        let locationContainerConstraints = [
            locationInformation.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            locationInformation.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            locationInformation.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32),
        ]
        
        [
            mapConstraints,
            locationContainerConstraints
        ].forEach { NSLayoutConstraint.activate($0) }
        
    }
    
    private func setupTheming() {
        
    }
    
    private func bindData() {

        viewModel.name.assign(to: \.locationName.value, on: locationInformation).store(in: &cancellables)
        viewModel.details.assign(to: \.locationDetails.value, on: locationInformation).store(in: &cancellables)

        annotationTask = Task { [weak self] in
            guard let self else { return }

            do {
                let annotation = try await self.viewModel.annotation()
                await MainActor.run {
                    let distance: CLLocationDistance = 1000
                    let region = MKCoordinateRegion(
                        center: annotation.coordinate,
                        latitudinalMeters: distance,
                        longitudinalMeters: distance
                    )

                    self.map.addAnnotation(annotation)
                    self.map.setCenter(annotation.coordinate, animated: true)
                    self.map.setRegion(region, animated: true)
                    self.coordinate = annotation.coordinate
                }
            } catch {
                // Keep current map state if geocoding fails.
            }
        }
        
    }

    deinit {
        annotationTask?.cancel()
    }
    
    // MARK: - Map Setup
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "identifier"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            
            annotationView?.canShowCallout = true
            
        } else {
            
            annotationView?.annotation = annotation
            
        }
        
        return annotationView
        
    }
    
}
