//
//  LocationManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 31.05.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func didReceiveCurrentLocation(location: CLLocation)
    func didFailWithError(error: Error)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared: LocationManager = LocationManager()
    
    public var delegate: LocationManagerDelegate? = nil
    public var lastLocation: CLLocation? { return locationManager.location }
    private let locationManager = CLLocationManager()
    private var authorizationCompletion: (() -> Void)?
    private var completion: ((CLLocation?, Error?) -> Void)?
    
    override init() {
        
        super.init()
        
        locationManager.delegate = self
        locationManager.activityType = .other
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    func getCurrentLocation(completion: @escaping ((CLLocation?, Error?) -> Void)) {
        
        self.locationManager.requestLocation()
        
        if let location = lastLocation {
            completion(location, nil)
            return
        }
        
        if let location = self.locationManager.location {
            completion(location, nil)
            return
        }
        
        self.completion = completion
        
    }
    
    func requestCurrentLocation() {
        
        locationManager.requestLocation()
        
    }
    
    func stopMonitoring() {
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            self.delegate?.didReceiveCurrentLocation(location: location)
            self.completion?(location, nil)
        } else {
            print("No Locations received")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        self.delegate?.didFailWithError(error: error)
        
        print("LocationManager failed with error: \(error.localizedDescription)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        authorizationCompletion?()
        
    }
    
    public func requestWhenInUseAuthorization(completion: (() -> Void)?) {
        
        self.authorizationCompletion = completion
        
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
}
