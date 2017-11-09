//
//  MapViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit
import Pulley

struct AnnotationIdentifier {
    
    static let cluster = "cluster"
    static let shop = "shop"
    static let parkingLot = "parkingLot"
    static let camera = "camera"
    
}

class MapViewController: UIViewController {

    // MARK: - UI
    
    @IBOutlet weak var map: MKMapView!
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        return manager
    }()
    
    private var locations: [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let moersRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.451667, longitude: 6.626389), span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        
        map.setRegion(moersRegion, animated: true)
        map.showsUserLocation = true
        map.showsBuildings = false
        map.showsPointsOfInterest = false
        map.mapType = .standard
        
        let api = API()
        
        api.delegate = self
        api.loadShop()
        api.loadParkingLots()
        api.loadCameras()
        
    }
    
}

extension MapViewController: APIDelegate {
    
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
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        } else if let cluster = annotation as? MKClusterAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.cluster) as? MKMarkerAnnotationView
            
            if view == nil { view = ClusterAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.cluster) }
            
            view?.annotation = cluster
            
            view?.collisionMode = .circle
            
            return view
            
        } else if let shop = annotation as? Shop {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.shop) as? MKMarkerAnnotationView
            
            if view == nil { view = ShopAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.shop) }
            
            view?.annotation = shop
            
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
            
        } else {
            
            return nil
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if !(view.annotation is MKClusterAnnotation) && !(view.annotation is MKUserLocation) {
            
            if let drawer = self.parent as? PulleyViewController {
                let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                drawer.setDrawerContentViewController(controller: drawerDetail, animated: false)
                drawer.setDrawerPosition(position: .collapsed, animated: true)
                
                drawerDetail.selectedLocation = view.annotation as? Location
                
            }
            
            guard let coordinate = view.annotation?.coordinate else { return }
            
            mapView.setCenter(coordinate, animated: true)
            
        } else if view.annotation is MKClusterAnnotation {
            
            if let drawer = self.parent as? PulleyViewController {
                let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
                
                drawer.setDrawerContentViewController(controller: drawerDetail, animated: false)
                drawer.setDrawerPosition(position: .collapsed, animated: true)
                
                guard let annotation = view.annotation as? MKClusterAnnotation else { return }
                
                guard let clusteredLocations = annotation.memberAnnotations as? [Location] else { return }
                
                drawerDetail.clusteredLocations = clusteredLocations
                
            }
            
            guard let coordinate = view.annotation?.coordinate else { return }
            
            mapView.setCenter(coordinate, animated: true)
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if let drawer = self.parent as? PulleyViewController {
            let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
            
            drawer.setDrawerContentViewController(controller: drawerDetail, animated: true)
            drawer.setDrawerPosition(position: .collapsed, animated: true)
            
        }
        
    }
    
}

extension MapViewController: PulleyPrimaryContentControllerDelegate {
    
    func makeUIAdjustmentsForFullscreen(progress: CGFloat) {
        
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat) {
        
    }
    
}
