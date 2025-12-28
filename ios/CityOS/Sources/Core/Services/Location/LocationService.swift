//
//  LocationService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import Combine

public protocol LocationService {
    
    /// Emits the current authorization status
    /// and all future changes.
    var authorizationStatuses: AsyncStream<CLAuthorizationStatus> { get }
    
    /// Emits location updates and may fail with an error.
    var locations: AsyncThrowingStream<CLLocation, Error> { get }
    
    /// Requests the when-in-use authorization via
    /// the underlying `CLLocationManager`.
    func requestWhenInUseAuthorization()
    
    /// Triggers the underlying `CLLocationManager` to
    /// request one location of the user.
    func requestCurrentLocation()
    
    /// Forces the underlying `CLLocationManager` to
    /// stop monitoring the user location.
    func stopMonitoring()
}
