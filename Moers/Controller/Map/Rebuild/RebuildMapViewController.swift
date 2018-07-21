//
//  RebuildMapViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit
import Pulley
import Crashlytics

class RebuildMapViewController: UIViewController, MKMapViewDelegate, PulleyPrimaryContentControllerDelegate {

    lazy var map: MKMapView = {
        
        let map = MKMapView()
        
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        
        return map
        
    }()
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.startUpdatingLocation()
        return manager
    }()
    
    private var locations: [Location] = []
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(map)
        
        let queue = OperationQueue()
        
        queue.addOperation {
        
            ShopManager.shared.get(completion: { (error, stores) in
                
                if let error = error {
                    print(error)
                }
                
                guard let stores = stores else { return }
                
                self.locations.append(contentsOf: stores)
                
                DispatchQueue.main.async {
                    
                    self.map.addAnnotations(stores)
                    
                }
                
            })
            
            API.shared.delegate = self
            
            API.shared.loadCameras()
            API.shared.loadParkingLots()
            API.shared.loadBikeChargingStations()
            
            self.populateData()
            
        }
        
        
        
        
        
//        let queue = OperationQueue()
//
//        queue.addOperation {
//
//
//
//            // TODO: !
//
//            API.shared.loadShop()
//            API.shared.loadCameras()
//            API.shared.loadParkingLots()
//            API.shared.loadBikeChargingStations()
//
//            self.populateData()
//
//        }
        
        self.setupConstraints()
        self.setupMap()
        
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
            
        } else if let store = annotation as? Store {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.shop) as? MKMarkerAnnotationView
            
            if view == nil { view = ShopAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.shop) }
            
            view?.annotation = store
            
            view?.collisionMode = .circle
            view?.clusteringIdentifier = AnnotationIdentifier.cluster
            view?.displayPriority = .defaultHigh
            
            return view
            
        } else if let parkingLot = annotation as? ParkingLot {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.parkingLot) as? MKMarkerAnnotationView
            
            if view == nil { view = ParkingLotAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.parkingLot) }
            
            view?.annotation = parkingLot
            
            view?.collisionMode = .circle
            view?.clusteringIdentifier = AnnotationIdentifier.cluster
            view?.displayPriority = .defaultHigh
            
            return view
            
        } else if let camera = annotation as? Camera {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.camera) as? MKMarkerAnnotationView
            
            if view == nil { view = CameraAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.camera) }
            
            view?.annotation = camera
            
            view?.collisionMode = .circle
            view?.clusteringIdentifier = AnnotationIdentifier.cluster
            view?.displayPriority = .defaultHigh
            
            return view
            
        } else if let bikeCharger = annotation as? BikeChargingStation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.bikeChargingStation) as? MKMarkerAnnotationView
            
            if view == nil { view = BikeChargingStationAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.bikeChargingStation) }
            
            view?.annotation = bikeCharger
            
            view?.collisionMode = .circle
            view?.clusteringIdentifier = AnnotationIdentifier.cluster
            view?.displayPriority = .defaultHigh
            
            return view
            
        } else {
            
            return nil
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        /*if !(view.annotation is MKClusterAnnotation) && !(view.annotation is MKUserLocation) {
            
            Answers.logCustomEvent(withName: "Map Selection", customAttributes: ["name": (view.annotation as! Location).name])
            
            if let drawer = self.parent as? PulleyViewController {
                
                let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                drawer.setDrawerContentViewController(controller: drawerDetail, animated: false)
                drawer.setDrawerPosition(position: .partiallyRevealed, animated: true)
                
                drawerDetail.selectedLocation = view.annotation as? Location
                
            }
            
            guard let coordinate = view.annotation?.coordinate else { return }
            
            mapView.setCenter(coordinate, animated: true)
            
        } else if view.annotation is MKClusterAnnotation {
            
            if let drawer = self.parent as? PulleyViewController {
                let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
                
                drawer.setDrawerContentViewController(controller: drawerDetail, animated: false)
                drawer.setDrawerPosition(position: .partiallyRevealed, animated: true)
                
                guard let annotation = view.annotation as? MKClusterAnnotation else { return }
                
                guard let clusteredLocations = annotation.memberAnnotations as? [Location] else { return }
                
                drawerDetail.clusteredLocations = clusteredLocations
                
            }
            
            guard let coordinate = view.annotation?.coordinate else { return }
            
            mapView.setCenter(coordinate, animated: true)
            
        }*/
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if let drawer = self.parent as? PulleyViewController {
            let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
            
            drawer.setDrawerContentViewController(controller: drawerDetail, animated: true)
            drawer.setDrawerPosition(position: .collapsed, animated: true)
            
        }
        
    }
    
    // MARK: - Private Methods
    
    private func setupMap() {
        
        let moersRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.451667, longitude: 6.626389), span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        
        map.setRegion(moersRegion, animated: true)
        map.showsUserLocation = true
        map.showsBuildings = false
        map.showsPointsOfInterest = false
        map.mapType = .standard
        
    }
    
    private func setupConstraints() {
        
        let constraints = [map.topAnchor.constraint(equalTo: self.view.topAnchor),
                           map.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           map.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func populateData() {
        
        self.locations.append(contentsOf: API.shared.cachedShops as [Location])
        self.locations.append(contentsOf: API.shared.cachedParkingLots as [Location])
        self.locations.append(contentsOf: API.shared.cachedCameras as [Location])
        self.locations.append(contentsOf: API.shared.cachedBikeCharger as [Location])
        
        self.map.addAnnotations(locations as! [MKAnnotation])
        
    }
    
    // MARK: - PulleyPrimaryContentControllerDelegate
    
    func makeUIAdjustmentsForFullscreen(progress: CGFloat) {
        
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat) {
        
    }
    
}

extension RebuildMapViewController: APIDelegate {
    
    func didReceiveShops(shops: [Shop]) {
        
        self.locations.append(contentsOf: shops as [Location])
        
        DispatchQueue.main.async {
            
            self.map.addAnnotations(shops)
            
        }
        
    }
    
    func didReceiveParkingLots(parkingLots: [ParkingLot]) {
        
        self.locations.append(contentsOf: parkingLots as [Location] )
        
        DispatchQueue.main.async {
            
            self.map.addAnnotations(parkingLots)
            
        }
        
    }
    
    func didReceiveCameras(cameras: [Camera]) {
        
        self.locations.append(contentsOf: cameras as [Location])
        
        DispatchQueue.main.async {
            
            self.map.addAnnotations(cameras)
            
        }
        
    }
    
    func didReceiveBikeChargers(chargers: [BikeChargingStation]) {
        
        self.locations.append(contentsOf: chargers as [Location])
        
        DispatchQueue.main.async {
            
            self.map.addAnnotations(chargers)
            
        }
        
    }
    
}
