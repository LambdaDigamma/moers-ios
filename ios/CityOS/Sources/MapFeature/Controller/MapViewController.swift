//
//  MapViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import SwiftUI
import MapKit

public class MapViewController: UIViewController, MKMapViewDelegate {

    lazy var map = { return CoreViewFactory.map() }()
    
    weak var container: MapContainerViewController?

    private var locations: [Location] = []
    private var isSelectingLocation = false
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupMap()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.view.backgroundColor = UIColor.systemBackground
        self.view.addSubview(map)
        
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            map.topAnchor.constraint(equalTo: self.view.topAnchor),
            map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    // MARK: - Map View -
    
    private func setupMap() {
        
        self.map.delegate = self
        self.map.mapType = .mutedStandard
        self.map.showsUserLocation = true
        self.map.showsBuildings = false
        self.map.pointOfInterestFilter = .none
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.451667, longitude: 6.626389),
            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        )
        
        self.map.setRegion(region, animated: true)
        
    }
    
    // MARK: - MKMapViewDelegate
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        } else if let cluster = annotation as? MKClusterAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.cluster) as? MKMarkerAnnotationView
            
            if view == nil { view = ClusterAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.cluster) }
            
            view?.annotation = cluster
            view?.collisionMode = .circle
            
            return view
            
        } else if let entry = annotation as? Entry {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.entry)
            
            if view == nil {
                view = EntryAnnotationView(annotation: entry, reuseIdentifier: AnnotationIdentifier.entry)
            } else {
                view?.annotation = entry
            }
            
            return view
            
        } else if let camera = annotation as? Camera {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.camera) as? MKMarkerAnnotationView
            
            if view == nil { view = CameraAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.camera) }
            
            view?.annotation = camera
            
            return view
            
        } else if let petrolStation = annotation as? PetrolStationViewModel {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.petrolStation) as? MKMarkerAnnotationView
            
            if view == nil { view = PetrolStationAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.petrolStation) }
            
            view?.annotation = petrolStation
            
            return view
            
        } else {
            return nil
        }
        
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard !isSelectingLocation, let annotation = view.annotation,
              mapView.selectedAnnotations.contains(where: { $0 === annotation }) else { return }
        let coordinate = annotation.coordinate
        
        self.map.setCenter(coordinate, animated: true)
        
        if let location = view.annotation as? Location {
            if container?.selectedLocation === location { return }
            container?.showLocation(location)
        } else if let cluster = view.annotation as? MKClusterAnnotation,
                  let locations = cluster.memberAnnotations as? [Location] {
            container?.showCluster(locations)
        }
    }

    func selectLocation(_ location: Location, animated: Bool) {
        isSelectingLocation = true
        defer { isSelectingLocation = false }
        map.selectAnnotation(location, animated: animated)
        map.setCenter(location.coordinate, animated: animated)
    }

    // MARK: - Public Methods
    
    public func addLocation(_ location: Location) {
        
        self.locations.append(location)
        
        DispatchQueue.main.async {
            self.map.addAnnotation(location)
        }
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

extension MapViewController: EntryDatasource, CameraDatasource, PetrolDatasource {
    
    func didReceiveEntries(_ entries: [Entry]) {
        
        DispatchQueue.main.async {
            self.map.removeAnnotations(self.locations.filter { $0 is Entry })
            self.locations = self.locations.filter { !($0 is Entry) }
            self.locations.append(contentsOf: entries as [Entry])
            self.map.addAnnotations(entries)
        }
        
    }
    
    func didReceiveCameras(_ cameras: [Camera]) {
        
        DispatchQueue.main.async {
            self.map.removeAnnotations(self.locations.filter { $0 is Camera })
            self.locations = self.locations.filter { !($0 is Camera) }
            self.locations.append(contentsOf: cameras as [Camera])
            self.map.addAnnotations(cameras)
        }
        
    }
    
    func didReceivePetrolStations(_ petrolStations: [PetrolStationViewModel]) {
        
        DispatchQueue.main.async {
            self.map.removeAnnotations(self.locations.filter { $0 is PetrolStationViewModel })
            self.locations = self.locations.filter { !($0 is PetrolStationViewModel) }
            self.locations.append(contentsOf: petrolStations as [PetrolStationViewModel])
            self.map.addAnnotations(petrolStations)
        }
        
    }
    
}

#Preview {
    MapViewController()
}
