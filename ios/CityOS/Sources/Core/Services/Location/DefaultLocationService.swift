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

public final class DefaultLocationService: NSObject, LocationService {

    private let locationManager: CLLocationManager
    private let logger: Logger

    // MARK: - Async Streams

    public let locations: AsyncThrowingStream<CLLocation, Error>
    public let authorizationStatuses: AsyncStream<CLAuthorizationStatus>

    // MARK: - Internal State

    private let locationContinuation: AsyncThrowingStream<CLLocation, Error>.Continuation
    private let authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation

    private var lastLocation: CLLocation?
    private var lastAuthorizationStatus: CLAuthorizationStatus

    // MARK: - Init

    public init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        self.logger = Logger(.coreApi)
        self.lastLocation = locationManager.location
        self.lastAuthorizationStatus = locationManager.authorizationStatus

        let (locationStream, locationContinuation) = AsyncThrowingStream.makeStream(of: CLLocation.self)
        self.locations = locationStream
        self.locationContinuation = locationContinuation

        let (authStream, authContinuation) = AsyncStream.makeStream(of: CLAuthorizationStatus.self)
        self.authorizationStatuses = authStream
        self.authorizationContinuation = authContinuation

        super.init()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Emit current authorization status immediately (CurrentValueSubject semantics)
        authContinuation.yield(locationManager.authorizationStatus)
        if let lastLocation {
            locationContinuation.yield(lastLocation)
        }

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
        locationContinuation.finish()
    }
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
            locationContinuation.yield(location)
        }
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        logger.error("CLLocationManager failed: \(error.localizedDescription, privacy: .public)")
        
        locationContinuation.finish(throwing: error)
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        logger.info("Authorization changed to \(status.name)")
        
        lastAuthorizationStatus = status
        authorizationContinuation.yield(status)
    }
}
