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
import MMAPI
import MMUI

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
    
    private let locationManager: LocationManagerProtocol
    private var entryManager: EntryManagerProtocol
    
    init(locationManager: LocationManagerProtocol, entryManager: EntryManagerProtocol) {
        self.locationManager = locationManager
        self.entryManager = entryManager
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        if entryManager.entryLat != 0 && entryManager.entryLng != 0 {
            
        } else {
            self.focusOnUserLocation()
        }
        
    }
    
    private func setupUI() {
        
        self.setupMap(centeringOn: CLLocationCoordinate2D(latitude: 51.4516, longitude: 6.6255))
        
        locationManager.authorizationStatus.observeNext { authorizationStatus in
            
            if authorizationStatus == .authorizedWhenInUse {
                self.locationManager.requestCurrentLocation()
                self.locationManager.location.receive(on: DispatchQueue.main)
                    .observeNext(with: { location in
                    self.setupMap(centeringOn: location.coordinate)
                }).dispose(in: self.bag)
            }
            
        }.dispose(in: bag)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
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
                           mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           mapView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),
                           pointer.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
                           pointer.centerYAnchor.constraint(equalTo: mapView.centerYAnchor), // , constant: 44
                           pointer.widthAnchor.constraint(equalToConstant: 20),
                           pointer.heightAnchor.constraint(equalTo: pointer.widthAnchor),
                           streetLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           streetLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           streetLabel.bottomAnchor.constraint(equalTo: self.promptLabel.topAnchor, constant: -16),
                           promptLabel.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -40),
                           promptLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           promptLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           userLocationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           userLocationButton.bottomAnchor.constraint(equalTo: streetLabel.topAnchor, constant: -8),
                           userLocationButton.widthAnchor.constraint(equalToConstant: 60),
                           userLocationButton.heightAnchor.constraint(equalTo: userLocationButton.widthAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupMap(centeringOn coordinate: CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
        mapView.setCenter(coordinate, animated: false)
        mapView.setRegion(region, animated: false)
        
    }
    
    @objc private func focusOnUserLocation() {
        
        locationManager.requestCurrentLocation()
        locationManager.location
            .receive(on: DispatchQueue.main)
            .observeNext { location in
            
            self.setupMap(centeringOn: location.coordinate)
            self.executeReverseGeocode()
            
        }.dispose(in: bag)
        
    }
    
    @objc private func continueOnboarding() {
        
        let coordinate = mapView.centerCoordinate
        
        entryManager.entryLat = coordinate.latitude
        entryManager.entryLng = coordinate.longitude
        entryManager.entryStreet = currentStreet
        entryManager.entryHouseNumber = currentHouseNumber
        entryManager.entryPlace = currentPlace
        entryManager.entryPostcode = currentPostcode
        
        let viewController = EntryOnboardingGeneralViewController(entryManager: entryManager)
        
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
        
        let coordinate = CLLocationCoordinate2D(latitude: entryManager.entryLat ?? 0, longitude: entryManager.entryLng ?? 0)
        
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
