//
//  MapViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit
import Pulley
import MMAPI
import MMUI

struct AnnotationIdentifier {
    
    static let cluster = "cluster"
    static let parkingLot = "parkingLot"
    static let camera = "camera"
    static let bikeChargingStation = "bikeCharger"
    static let petrolStation = "petrolStation"
    static let entry = "entry"
    
}

class MapViewController: UIViewController, MKMapViewDelegate, PulleyPrimaryContentControllerDelegate {

    lazy var map = { return ViewFactory.map() }()
    
    // swiftlint:disable:next force_cast
    lazy var drawer = { return self.parent as! MainViewController }()
    
    private let locationManager: LocationManagerProtocol
    private var locations: [Location] = []
    
    init(locationManager: LocationManagerProtocol) {
        self.locationManager = locationManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
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
            
        } else if let parkingLot = annotation as? ParkingLot {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.parkingLot) as? MKMarkerAnnotationView
            
            if view == nil { view = ParkingLotAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.parkingLot) }
            
            view?.annotation = parkingLot
            
            return view
            
        } else if let camera = annotation as? Camera {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.camera) as? MKMarkerAnnotationView
            
            if view == nil { view = CameraAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.camera) }
            
            view?.annotation = camera
            
            return view
            
        } else if let petrolStation = annotation as? PetrolStation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.petrolStation) as? MKMarkerAnnotationView
            
            if view == nil { view = PetrolStationAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.petrolStation) }
            
            view?.annotation = petrolStation
            
            return view
            
        } else {
            return nil
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let coordinate = view.annotation?.coordinate else { return }
        
        self.map.setCenter(coordinate, animated: true)
        
        if !(view.annotation is MKClusterAnnotation) && !(view.annotation is MKUserLocation) {
            
            self.setDrawerController(drawer.detailViewController, position: .partiallyRevealed)
            self.drawer.detailViewController.selectedLocation = view.annotation as? Location
            
            guard let location = view.annotation as? Location else { return }
            
            AnalyticsManager.shared.logSelectedItem(location)
            
        } else if view.annotation is MKClusterAnnotation {
            
            guard let annotation = view.annotation as? MKClusterAnnotation else { return }
            guard let clusteredLocations = annotation.memberAnnotations as? [Location] else { return }
            
            let selectionController = SelectionViewController()
            
            selectionController.clusteredLocations = clusteredLocations
            selectionController.annotation = annotation
            
            self.setDrawerController(selectionController, position: .partiallyRevealed)
            
            AnalyticsManager.shared.logSelectedCluster(with: annotation.memberAnnotations.count)
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        setDrawerController(drawer.contentViewController)
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.map.delegate = self
        
        self.view.addSubview(map)
        
        map.showsUserLocation = true
        map.showsBuildings = false
        map.pointOfInterestFilter = .none
        map.mapType = .standard
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.451667, longitude: 6.626389),
                                        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012))
        
        map.setRegion(region, animated: true)
        
//        locationManager.authorizationStatus.observeNext { authorizationStatus in
//
//            let region = MKCoordinateRegion(center: self.map.userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
//
//            self.map.setRegion(region, animated: true)
//
//        }.dispose(in: bag)
        
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
    
    private func setDrawerController(_ controller: UIViewController, position: PulleyPosition = .collapsed) {
        
        drawer.setDrawerContentViewController(controller: controller, animated: true)
        drawer.setDrawerPosition(position: position, animated: true)
        
    }
    
    // MARK: - Public Methods
    
    public func addLocation(_ location: Location) {
        
        self.locations.append(location)
        
        DispatchQueue.main.async {
            self.map.addAnnotation(location)
        }
        
    }
    
}

extension MapViewController: EntryDatasource, ParkingLotDatasource, CameraDatasource, PetrolDatasource {
    
    func didReceiveEntries(_ entries: [Entry]) {
        
        DispatchQueue.main.async {
            self.map.removeAnnotations(self.locations.filter { $0 is Entry })
            self.locations = self.locations.filter { !($0 is Entry) }
            self.locations.append(contentsOf: entries as [Entry])
            self.map.addAnnotations(entries)
        }
        
    }
    
    func didReceiveParkingLots(_ parkingLots: [ParkingLot]) {
        
        DispatchQueue.main.async {
            self.map.removeAnnotations(self.locations.filter { $0 is ParkingLot })
            self.locations = self.locations.filter { !($0 is ParkingLot) }
            self.locations.append(contentsOf: parkingLots as [ParkingLot])
            self.map.addAnnotations(parkingLots)
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
    
    func didReceivePetrolStations(_ petrolStations: [PetrolStation]) {
        
        DispatchQueue.main.async {
            self.map.removeAnnotations(self.locations.filter { $0 is PetrolStation })
            self.locations = self.locations.filter { !($0 is PetrolStation) }
            self.locations.append(contentsOf: petrolStations as [PetrolStation])
            self.map.addAnnotations(petrolStations)
        }
        
    }
    
}
