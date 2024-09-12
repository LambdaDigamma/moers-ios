//
//  StaticLocationService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import Combine

public class StaticLocationService: LocationService {
    
    public var authorizationStatus: CurrentValueSubject<CLAuthorizationStatus, Never>
    public var location: CurrentValueSubject<CLLocation, Error>
    
    public init(
        authorizationStatus: CLAuthorizationStatus = .authorizedAlways,
        initialLocation: CLLocation = CoreSettings.regionLocation
    ) {
        self.authorizationStatus = CurrentValueSubject(authorizationStatus)
        self.location = CurrentValueSubject(initialLocation)
    }
    
    public func requestWhenInUseAuthorization() {
        authorizationStatus.value = .authorizedWhenInUse
    }
    
    public func requestCurrentLocation() {
        location.value = CLLocation(
            latitude: CoreSettings.regionCenter.latitude,
            longitude: CoreSettings.regionCenter.longitude
        )
    }
    
    public func stopMonitoring() {
        
    }
    
}
