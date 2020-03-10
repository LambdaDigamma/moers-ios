//
//  ARNavigationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 04.03.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI
import MMUI
import MapKit
import ARKit_CoreLocation

class ARNavigationViewController: UIViewController {

    private lazy var mapView: MKMapView = { ViewFactory.map() }()
    private var sceneLocationView = SceneLocationView()
    
    private let showDebugging = true
    private let centerMapOnUserLocation = true
    
    private let locationManager = CLLocationManager()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneLocationView.run()
        
        self.setupApplicationLifecycleHooks()
        self.setupUI()
        self.setupConstraints()
        self.setupAR()
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingHeading()
        self.locationManager.startUpdatingLocation()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupMap()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.sceneLocationView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(sceneLocationView)
        self.view.addSubview(mapView)
        
        self.mapView.layer.cornerRadius = 8
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            sceneLocationView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneLocationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneLocationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            sceneLocationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -16),
            mapView.leadingAnchor.constraint(equalTo: self.safeLeftAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: self.safeRightAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupApplicationLifecycleHooks() {
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
                                                self?.pauseARAnimation()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
                                                self?.restartARAnimation()
        }
        
    }
    
    // MARK: - Setup AR
    
    private func setupAR() {
        
        if showDebugging {
            sceneLocationView.showAxesNode = true
            sceneLocationView.showFeaturePoints = showDebugging
        }
        
        sceneLocationView.autoenablesDefaultLighting = true
        
        generateLocationNodes().forEach {
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
        }
        
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: generateLocationNodes()[0])
        
    }
    
    private func restartARAnimation() {
        self.sceneLocationView.run()
    }
    
    private func pauseARAnimation() {
        self.sceneLocationView.pause()
    }
    
    // MARK: - Building AR Scene
    
    private func generateLocationNodes() -> [LocationAnnotationNode] {
        
        var nodes: [LocationAnnotationNode] = []
        
        let churchLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4513, longitude: 6.6257), altitude: 225)
        let churchNode = generateLocationNode(for: churchLocation, imageName: "pin")
        nodes.append(churchNode)
        
        return nodes
        
    }
    
    private func generateLocationNode(for location: CLLocation, imageName: String) -> LocationAnnotationNode {
        
        guard let image = UIImage(named: imageName) else { return LocationAnnotationNode(location: location, view: UIView()) }
        
        return LocationAnnotationNode(location: location, image: image)
        
    }
    
    // MARK: - Building Map
    
    private func setupMap() {
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false
        self.mapView.mapType = .standard
        self.mapView.isPitchEnabled = false
        self.mapView.isRotateEnabled = false
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = false
        self.mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.451667, longitude: 6.626389),
                                        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012))
        
        self.mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.4513, longitude: 6.6257)
        
        self.mapView.addAnnotation(annotation)
        
    }
    
}

extension ARNavigationViewController: LNTouchDelegate {
    
    func annotationNodeTouched(node: AnnotationNode) {
        
    }
    
    func locationNodeTouched(node: LocationNode) {
        
    }
    
}

extension ARNavigationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapView.camera.heading = newHeading.magneticHeading
        mapView.setCamera(mapView.camera, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
}

extension ARNavigationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        } else if let cluster = annotation as? MKClusterAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.cluster) as? MKMarkerAnnotationView
            
            if view == nil { view = ClusterAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.cluster) }
            
            view?.annotation = cluster
            view?.collisionMode = .circle
            
            return view
            
        } else {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.entry)
            
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "hey")
            } else {
                view?.annotation = annotation
            }
            
            return view
            
        }
        
    }
    
}

extension DispatchQueue {
    
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                        execute: execute)
    }
    
}
