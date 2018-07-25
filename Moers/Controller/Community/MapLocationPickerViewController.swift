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
    lazy var checkButton = { return ViewFactory.button() }()
    
    weak var delegate: MapLocationPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.addSubview(mapView)
        self.view.addSubview(pointer)
        self.view.addSubview(promptLabel)
        self.view.addSubview(streetLabel)
        self.view.addSubview(checkButton)
        
        self.setupConstraints()
        self.setupUI()
        
    }
    
    private func setupUI() {

        let coordinate = CLLocationCoordinate2D(latitude: 51.4516, longitude: 6.6255)
        
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
        promptLabel.text = "Bewege das Fadenkreuz auf das Geschäft auf der Karte!"
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
        checkButton.setImage(#imageLiteral(resourceName: "checkmark").withRenderingMode(.alwaysTemplate), for: .normal)
        checkButton.tintColor = UIColor.white
        checkButton.setBackgroundColor(color: UIColor.black, forState: .normal)
        checkButton.layer.cornerRadius = 30
        checkButton.clipsToBounds = true
        checkButton.addTarget(self, action: #selector(selectedCoordinate), for: .touchUpInside)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [mapView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           mapView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),
                           pointer.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
                           pointer.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
                           pointer.widthAnchor.constraint(equalToConstant: 20),
                           pointer.heightAnchor.constraint(equalTo: pointer.widthAnchor),
                           streetLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           streetLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           streetLabel.bottomAnchor.constraint(equalTo: self.promptLabel.topAnchor, constant: -16),
                           promptLabel.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -40),
                           promptLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           promptLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           checkButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           checkButton.bottomAnchor.constraint(equalTo: streetLabel.topAnchor, constant: -8),
                           checkButton.widthAnchor.constraint(equalToConstant: 60),
                           checkButton.heightAnchor.constraint(equalTo: checkButton.widthAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc private func selectedCoordinate() {
        
        let coordinate = mapView.camera.centerCoordinate
        
        delegate?.selectedCoordinate(coordinate)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension MapLocationPickerViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let coordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            guard let placemark = placemarks?.first else { return }
            
            self.streetLabel.text = "\(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
            
        }
        
    }
    
}
