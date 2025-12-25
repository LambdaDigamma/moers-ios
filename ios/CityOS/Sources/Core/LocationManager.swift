//
//  LocationManager.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

public protocol LocationManagerProtocol {
    
    var authorizationStatus: CurrentValueSubject<CLAuthorizationStatus, Never> { get }
    var location: CurrentValueSubject<CLLocation, Error> { get }
    
    func requestWhenInUseAuthorization()
    func requestCurrentLocation()
    func stopMonitoring()
    func updateDistances(locations: [Location]) -> AnyPublisher<[Location], Error>
    func updateDistances<T: Location>(locations: [T]) -> AnyPublisher<[T], Error>
    
}

public class LocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    
    public var location: CurrentValueSubject<CLLocation, Error>
    public var authorizationStatus: CurrentValueSubject<CLAuthorizationStatus, Never>
    
    public init(locationManager: CLLocationManager = CLLocationManager()) {
        
        self.location = CurrentValueSubject(locationManager.location ?? CLLocation())
        self.locationManager = locationManager
        self.authorizationStatus = CurrentValueSubject(locationManager.authorizationStatus)
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        #if os(watchOS)
        if #available(watchOS 4.0, *) {
            self.locationService.activityType = .other
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
    
    public func updateDistances(locations: [Location]) -> AnyPublisher<[Location], Error> {
        
        #if os(macOS)
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            return location.map { userLocation -> [Location] in
                
                locations.forEach({ location in
                    location.distance = Measurement<UnitLength>(
                        value: userLocation.distance(from: location.location),
                        unit: .meters
                    )
                })
                
                return locations
                
            }
            
        } else {
            return Signal.failed(APIError.notAuthorized)
        }
        #endif
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            
            return location.map { userLocation -> [Location] in
                
                locations.forEach({ location in
                    location.distance = Measurement(value: userLocation.distance(from: location.location), unit: .meters)
                })
                
                return locations
                
            }.eraseToAnyPublisher()
            
        } else {
            return Fail(error: APIError.notAuthorized).eraseToAnyPublisher()
        }
        #endif
        
    }
    
    public func updateDistances<T: Location>(locations: [T]) -> AnyPublisher<[T], Error> {
        
        #if os(macOS)
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            return location.map { userLocation -> [T] in
                
                locations.forEach({ location in
                    location.distance = Measurement(
                        value: userLocation.distance(from: location.location),
                        unit: .meters
                    )
                })
                
                return locations
                
            }
            
        } else {
            return Signal.failed(APIError.notAuthorized)
        }
        
        #else
        
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            
            return location.map { userLocation -> [T] in
                
                locations.forEach({ location in
                    location.distance = Measurement(value: userLocation.distance(from: location.location), unit: .meters)
                })
                
                return locations
                
            }.eraseToAnyPublisher()
            
        } else {
            return Fail(error: APIError.notAuthorized).eraseToAnyPublisher()
        }
        
        #endif
    
        
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Received Location Updates")
        locations.forEach { self.location.send($0) }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.location.send(completion: .failure(error))
        self.location = CurrentValueSubject(CLLocation())
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus.send(status)
    }
    
}
