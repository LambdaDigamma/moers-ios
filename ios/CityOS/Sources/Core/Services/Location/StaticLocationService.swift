//
//  StaticLocationService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import Combine

@MainActor
public final class StaticLocationService: LocationService {

    // MARK: - Streams

    public var authorizationStatus: CLAuthorizationStatus {
        currentAuthorizationStatus
    }

    public var authorizationStatuses: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            let id = UUID()
            authorizationContinuations[id] = continuation
            continuation.yield(currentAuthorizationStatus)

            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.authorizationContinuations[id] = nil
                }
            }
        }
    }

    public var locations: AsyncThrowingStream<CLLocation, Error> {
        AsyncThrowingStream { continuation in
            let id = UUID()
            locationContinuations[id] = continuation
            continuation.yield(currentLocation)

            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.locationContinuations[id] = nil
                }
            }
        }
    }

    // MARK: - Internal State

    private var currentAuthorizationStatus: CLAuthorizationStatus
    private var currentLocation: CLLocation

    private var authorizationContinuations: [UUID: AsyncStream<CLAuthorizationStatus>.Continuation] = [:]
    private var locationContinuations: [UUID: AsyncThrowingStream<CLLocation, Error>.Continuation] = [:]

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
        authorizationContinuations.values.forEach { $0.yield(.authorizedWhenInUse) }
    }
    
    public func requestCurrentLocation() {
        let location = CLLocation(
            latitude: CoreSettings.regionCenter.latitude,
            longitude: CoreSettings.regionCenter.longitude
        )
        
        currentLocation = location
        locationContinuations.values.forEach { $0.yield(location) }
    }

    public func stopMonitoring() {
        // No-op (static service)
    }
    
    public func configureLocation(_ location: CLLocation) {
        currentLocation = location
        locationContinuations.values.forEach { $0.yield(location) }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
