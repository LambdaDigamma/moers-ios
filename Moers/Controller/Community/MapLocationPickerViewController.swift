//
//  MapLocationPickerViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapLocationPickerViewControllerDelegate:class {
    
    func selectedCoordinate(_ coordinate: CLLocationCoordinate2D)
    
}

class MapLocationPickerViewController: UIViewController {
    
    lazy var mapView = { return ViewFactory.map() }()
    lazy var pointer = { return ViewFactory.imageView() }()
    lazy var promptLabel = { return ViewFactory.paddingLabel() }()
    lazy var streetLabel = { return ViewFactory.paddingLabel() }()
    lazy var userLocationButton = { return ViewFactory.button() }()
    
    private var currentStreet: String = ""
    private var currentHouseNumber: String = ""
    private var currentPlace: String = ""
    private var currentPostcode: String = ""
    
    weak var delegate: MapLocationPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.addSubview(mapView)
        self.view.addSubview(pointer)
        self.view.addSubview(promptLabel)
        self.view.addSubview(streetLabel)
        self.view.addSubview(userLocationButton)
        
        self.setupConstraints()
        self.setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if EntryManager.shared.entryLat != 0 && EntryManager.shared.entryLng != 0 {
            
        } else {
            self.focusOnUserLocation()
        }
        
    }
    
    private func setupUI() {
        
        let coordinate = LocationManager.shared.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 51.4516, longitude: 6.6255)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)) // 0.0015
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setCenter(coordinate, animated: false)
        mapView.setRegion(region, animated: false)
        pointer.image = #imageLiteral(resourceName: "geolocation").withRenderingMode(.alwaysTemplate)
        pointer.tintColor = UIColor.black
        promptLabel.backgroundColor = UIColor.darkGray
        promptLabel.textColor = UIColor.white
        promptLabel.textAlignment = .center
        promptLabel.text = String.localized("PickerPromptText")
        promptLabel.numberOfLines = 0
        promptLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        promptLabel.layer.cornerRadius = 8
        promptLabel.clipsToBounds = true
        streetLabel.backgroundColor = UIColor.gray
        streetLabel.textColor = UIColor.white
        streetLabel.textAlignment = .center
        streetLabel.numberOfLines = 0
        streetLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        streetLabel.layer.cornerRadius = 8
        streetLabel.clipsToBounds = true
        userLocationButton.setImage(#imageLiteral(resourceName: "geolocation").withRenderingMode(.alwaysTemplate), for: .normal)
        userLocationButton.tintColor = UIColor.white
        userLocationButton.setBackgroundColor(color: UIColor.black, forState: .normal)
        userLocationButton.layer.cornerRadius = 30
        userLocationButton.clipsToBounds = true
        userLocationButton.addTarget(self, action: #selector(focusOnUserLocation), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Weiter", style: .plain, target: self, action: #selector(continueOnboarding))
        
        executeReverseGeocode()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [mapView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           mapView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),
                           pointer.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
                           pointer.centerYAnchor.constraint(equalTo: mapView.centerYAnchor), // , constant: 44
                           pointer.widthAnchor.constraint(equalToConstant: 20),
                           pointer.heightAnchor.constraint(equalTo: pointer.widthAnchor),
                           streetLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           streetLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           streetLabel.bottomAnchor.constraint(equalTo: self.promptLabel.topAnchor, constant: -16),
                           promptLabel.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -40),
                           promptLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           promptLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           userLocationButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           userLocationButton.bottomAnchor.constraint(equalTo: streetLabel.topAnchor, constant: -8),
                           userLocationButton.widthAnchor.constraint(equalToConstant: 60),
                           userLocationButton.heightAnchor.constraint(equalTo: userLocationButton.widthAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc private func focusOnUserLocation() {
        
        if let coordinate = LocationManager.shared.lastLocation?.coordinate {
            
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)) // 0.0015
            
            mapView.setCenter(coordinate, animated: true)
            mapView.setRegion(region, animated: true)
            
            executeReverseGeocode()
            
        }
        
    }
    
    @objc private func continueOnboarding() {
        
        let coordinate = mapView.centerCoordinate
        
        EntryManager.shared.entryLat = coordinate.latitude
        EntryManager.shared.entryLng = coordinate.longitude
        EntryManager.shared.entryStreet = currentStreet
        EntryManager.shared.entryHouseNumber = currentHouseNumber
        EntryManager.shared.entryPlace = currentPlace
        EntryManager.shared.entryPostcode = currentPostcode
        
        let viewController = EntryOnboardingGeneralViewController()
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    private func executeReverseGeocode() {
        
        let coordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            guard let placemark = placemarks?.first else { return }
            
            self.currentStreet = placemark.thoroughfare ?? ""
            self.currentHouseNumber = placemark.subThoroughfare ?? ""
            self.currentPostcode = placemark.postalCode ?? ""
            self.currentPlace = placemark.locality ?? ""
            
            self.streetLabel.text = "\(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
            
        }
        
    }
    
    private func focusOnPreviousLocation() {
        
        let coordinate = CLLocationCoordinate2D(latitude: EntryManager.shared.entryLat ?? 0, longitude: EntryManager.shared.entryLng ?? 0)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)) // 0.0015
            
        mapView.setCenter(coordinate, animated: true)
        mapView.setRegion(region, animated: true)
            
        executeReverseGeocode()
        
    }
    
}

extension MapLocationPickerViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        executeReverseGeocode()
        
    }
    
}
