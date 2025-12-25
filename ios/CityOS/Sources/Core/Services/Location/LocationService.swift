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
    
    /// Sends the current authorization status
    /// and publishes changes to it.
    var authorizationStatus: CurrentValueSubject<CLAuthorizationStatus, Never> { get }
    
    var location: CurrentValueSubject<CLLocation, Error> { get }
    
    /// Requests the when-in-use authorization via
    /// the underlaying `CLLocationManager`.
    func requestWhenInUseAuthorization()
    
    /// Trigger the underlaying `CLLocationManager` to
    /// request one location of the user. That location is then
    /// asychronously being pushed to the location subject.
    func requestCurrentLocation()
    
    /// Force the underlaying `CLLocationManager` to
    /// stop monitoring the user location.
    func stopMonitoring()
    
}
