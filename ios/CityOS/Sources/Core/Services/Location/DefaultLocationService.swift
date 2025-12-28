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
    
    public var locations: AsyncThrowingStream<CLLocation, Error> {
        AsyncThrowingStream { continuation in
            self.locationContinuation = continuation
            
            // Emit current value immediately (CurrentValueSubject semantics)
            if let lastLocation {
                continuation.yield(lastLocation)
            }
        }
    }
    
    public var authorizationStatuses: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            self.authorizationContinuation = continuation
            
            // Emit current value immediately
            continuation.yield(self.lastAuthorizationStatus)
        }
    }
    
    // MARK: - Internal State
    
    private var locationContinuation: AsyncThrowingStream<CLLocation, Error>.Continuation?
    private var authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation?
    
    private var lastLocation: CLLocation?
    private var lastAuthorizationStatus: CLAuthorizationStatus
    
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
            locationContinuation?.yield(location)
        }
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        logger.error("CLLocationManager failed: \(error.localizedDescription, privacy: .public)")
        
        locationContinuation?.finish(throwing: error)
        locationContinuation = nil
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        logger.info("Authorization changed to \(status.name)")
        
        lastAuthorizationStatus = status
        authorizationContinuation?.yield(status)
    }
}
