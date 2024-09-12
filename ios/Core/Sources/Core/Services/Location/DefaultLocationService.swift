//
//  DefaultLocationService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import Combine
import OSLog

extension CLAuthorizationStatus: CaseName {
    
    public var name: String {
        switch self {
            case .notDetermined:
                return "notDetermined"
            case .restricted:
                return "restricted"
            case .denied:
                return "denied"
            case .authorizedAlways:
                return "authorizedAlways"
            case .authorizedWhenInUse:
                return "authorizedWhenInUse"
            case .authorized:
                return "authorized"
            @unknown default:
                return "unknown default"
        }
    }
    
}

public class DefaultLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    private let logger: Logger
    
    public var location: CurrentValueSubject<CLLocation, Error>
    public var authorizationStatus: CurrentValueSubject<CLAuthorizationStatus, Never>
    
    public init(locationManager: CLLocationManager = CLLocationManager()) {
        
        self.logger = Logger(.coreApi)
        self.location = CurrentValueSubject(locationManager.location ?? CLLocation())
        self.locationManager = locationManager
        self.authorizationStatus = CurrentValueSubject(locationManager.authorizationStatus)
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
#if os(watchOS)
        if #available(watchOS 4.0, *) {
            self.locationManager.activityType = .other
        }
#endif
        
        self.authorizationStatus.send(locationManager.authorizationStatus)
        
    }
    
    public func requestWhenInUseAuthorization() {
        if locationManager.authorizationStatus == .notDetermined {
#if os(macOS)
            locationManager.requestAlwaysAuthorization()
#else
            locationManager.requestWhenInUseAuthorization()
#endif
        }
    }
    
    public func requestCurrentLocation() {
        locationManager.requestLocation()
    }
    
    public func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        logger.log("Received location updates and sending them all onto the location subject")
        
        locations.forEach { self.location.send($0) }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        logger.error("CLLocationManager failed with error: \(error.localizedDescription, privacy: .public)")
        
        self.location.send(completion: .failure(error))
        self.location = CurrentValueSubject(CLLocation())
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        logger.info("CLLocationManager changed authorization to \(status.name)")
        
        self.authorizationStatus.send(status)
    }
    
}
