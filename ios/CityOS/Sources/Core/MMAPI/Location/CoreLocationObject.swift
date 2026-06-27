//
//  CoreLocationObject.swift
//  
//
//  Created by Lennart Fischer on 25.10.20.
//

import Combine
import CoreLocation
import SwiftUI

@Observable
public class CoreLocationObject {
    
    public var authorizationStatus = CLAuthorizationStatus.notDetermined
    public var location: CLLocation?
    public var heading: CLHeading?
    
    @ObservationIgnored
    let manager: CLLocationManager
    @ObservationIgnored
    let publicist: CLLocationManagerCombineDelegate
    
    @ObservationIgnored
    var cancellables = [AnyCancellable]()
    
    public init() {
        let manager = CLLocationManager()
        let publicist = CLLocationManagerPublicist()
        
        manager.delegate = publicist
        
        self.manager = manager
        self.publicist = publicist
        
        let authorizationPublisher = publicist.authorizationPublisher()
        let locationPublisher = locationPublisher()
        let headingPublisher = publicist.headingPublisher()
        
        // trigger an update when authorization changes
        authorizationPublisher
            .sink(receiveValue: beginUpdates)
            .store(in: &cancellables)
        
        authorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authorizationStatus in
                self?.authorizationStatus = authorizationStatus
            }
            .store(in: &cancellables)

        locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.location = location
            }
            .store(in: &cancellables)

        headingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] heading in
                self?.heading = heading
            }
            .store(in: &cancellables)
    }
    
    public func authorize() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    public func locationPublisher() -> AnyPublisher<CLLocation?, Never> {
        publicist.locationPublisher()
            .flatMap(Publishers.Sequence.init(sequence:))
            .map { $0 as CLLocation? }
            .eraseToAnyPublisher()
    }
    
    public func beginUpdates(_ authorizationStatus: CLAuthorizationStatus) {
        #if !os(tvOS) && !os(macOS)
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
        #endif
    }
    
    public func beginUpdatingHeading(_ authorizationStatus: CLAuthorizationStatus) {
#if !os(tvOS) && !os(macOS)
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingHeading()
        }
#endif
    }
    
    
    public func endUpdates() {
        manager.stopUpdatingLocation()
    }
    
    public func endUpdatingHeading() {
        manager.stopUpdatingHeading()
    }
    
}
