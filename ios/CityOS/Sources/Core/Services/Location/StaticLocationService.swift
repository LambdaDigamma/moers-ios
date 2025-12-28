//
//  StaticLocationService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import Combine

public final class StaticLocationService: LocationService {
    
    // MARK: - Streams
    
    public var authorizationStatuses: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            self.authorizationContinuation = continuation
            continuation.yield(currentAuthorizationStatus)
        }
    }
    
    public var locations: AsyncThrowingStream<CLLocation, Error> {
        AsyncThrowingStream { continuation in
            self.locationContinuation = continuation
            continuation.yield(currentLocation)
        }
    }
    
    // MARK: - Internal State
    
    private var currentAuthorizationStatus: CLAuthorizationStatus
    private var currentLocation: CLLocation
    
    private var authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation?
    private var locationContinuation: AsyncThrowingStream<CLLocation, Error>.Continuation?
    
    // MARK: - Init
    
    public init(
        authorizationStatus: CLAuthorizationStatus = .authorizedAlways,
        initialLocation: CLLocation = CoreSettings.regionLocation
    ) {
        self.currentAuthorizationStatus = authorizationStatus
        self.currentLocation = initialLocation
    }
    
    // MARK: - Public API
    
    public func requestWhenInUseAuthorization() {
        currentAuthorizationStatus = .authorizedWhenInUse
        authorizationContinuation?.yield(.authorizedWhenInUse)
    }
    
    public func requestCurrentLocation() {
        let location = CLLocation(
            latitude: CoreSettings.regionCenter.latitude,
            longitude: CoreSettings.regionCenter.longitude
        )
        
        currentLocation = location
        locationContinuation?.yield(location)
    }
    
    public func stopMonitoring() {
        // No-op (static service)
    }
    
    public func configureLocation(_ location: CLLocation) {
        currentLocation = location
        locationContinuation?.yield(location)
    }
}
