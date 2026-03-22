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

    public let authorizationStatuses: AsyncStream<CLAuthorizationStatus>
    public let locations: AsyncThrowingStream<CLLocation, Error>

    // MARK: - Internal State

    private var currentAuthorizationStatus: CLAuthorizationStatus
    private var currentLocation: CLLocation

    private let authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation
    private let locationContinuation: AsyncThrowingStream<CLLocation, Error>.Continuation

    // MARK: - Init

    public init(
        authorizationStatus: CLAuthorizationStatus = .authorizedAlways,
        initialLocation: CLLocation = CoreSettings.regionLocation
    ) {
        self.currentAuthorizationStatus = authorizationStatus
        self.currentLocation = initialLocation

        let (authStream, authContinuation) = AsyncStream.makeStream(of: CLAuthorizationStatus.self)
        self.authorizationStatuses = authStream
        self.authorizationContinuation = authContinuation

        let (locationStream, locationContinuation) = AsyncThrowingStream.makeStream(of: CLLocation.self)
        self.locations = locationStream
        self.locationContinuation = locationContinuation

        authContinuation.yield(authorizationStatus)
        locationContinuation.yield(initialLocation)
    }
    
    // MARK: - Public API
    
    public func requestWhenInUseAuthorization() {
        currentAuthorizationStatus = .authorizedWhenInUse
        authorizationContinuation.yield(.authorizedWhenInUse)
    }
    
    public func requestCurrentLocation() {
        let location = CLLocation(
            latitude: CoreSettings.regionCenter.latitude,
            longitude: CoreSettings.regionCenter.longitude
        )
        
        currentLocation = location
        locationContinuation.yield(location)
    }

    public func stopMonitoring() {
        // No-op (static service)
    }
    
    public func configureLocation(_ location: CLLocation) {
        currentLocation = location
        locationContinuation.yield(location)
    }
}
