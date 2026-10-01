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
#if !os(tvOS)
            case .authorized:
                return "authorized"
#endif
            @unknown default:
                return "unknown default"
        }
    }
    
}

@MainActor
public final class DefaultLocationService: NSObject, LocationService {

    private let locationManager: CLLocationManager
    private let logger: Logger

    // MARK: - Async Streams

    public var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    public var locations: AsyncThrowingStream<CLLocation, Error> {
        AsyncThrowingStream { continuation in
            let id = UUID()
            locationContinuations[id] = continuation

            if let lastLocation {
                continuation.yield(lastLocation)
            }

            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.locationContinuations[id] = nil
                }
            }
        }
    }

    public var authorizationStatuses: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            let id = UUID()
            authorizationContinuations[id] = continuation
            continuation.yield(lastAuthorizationStatus)

            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.authorizationContinuations[id] = nil
                }
            }
        }
    }

    // MARK: - Internal State

    private var lastLocation: CLLocation?
    private var lastAuthorizationStatus: CLAuthorizationStatus
    private var locationContinuations: [UUID: AsyncThrowingStream<CLLocation, Error>.Continuation] = [:]
    private var authorizationContinuations: [UUID: AsyncStream<CLAuthorizationStatus>.Continuation] = [:]

    // MARK: - Init

    public init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        self.logger = Logger(.coreApi)
        self.lastLocation = locationManager.location
        self.lastAuthorizationStatus = locationManager.authorizationStatus

        super.init()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

#if os(watchOS)
        if #available(watchOS 4.0, *) {
            self.locationManager.activityType = .other
        }
#endif
    }
    
    // MARK: - Public API
    
    public func requestWhenInUseAuthorization() {
        guard locationManager.authorizationStatus == .notDetermined else { return }
        
#if os(macOS)
        locationManager.requestAlwaysAuthorization()
#else
        locationManager.requestWhenInUseAuthorization()
#endif
    }
    
    public func requestCurrentLocation() {
        locationManager.requestLocation()
    }
    
    public func stopMonitoring() {
        locationManager.stopUpdatingLocation()
        locationContinuations.values.forEach { $0.finish() }
        locationContinuations.removeAll()
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

// MARK: - CLLocationManagerDelegate

extension DefaultLocationService: CLLocationManagerDelegate {
    
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        logger.log("Received location updates")
        
        for location in locations {
            lastLocation = location
            locationContinuations.values.forEach { $0.yield(location) }
        }
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        logger.error("CLLocationManager failed: \(error.localizedDescription, privacy: .public)")
        
        locationContinuations.values.forEach { $0.finish(throwing: error) }
        locationContinuations.removeAll()
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        logger.info("Authorization changed to \(status.name)")
        
        lastAuthorizationStatus = status
        authorizationContinuations.values.forEach { $0.yield(status) }
    }
}
