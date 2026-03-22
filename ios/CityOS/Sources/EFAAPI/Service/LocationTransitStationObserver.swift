//
//  LocationStationObserver.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import Foundation
import Factory
import CoreLocation
import Combine
import ModernNetworking

public class DefaultLocationTransitStationObserver {
    
    @Injected(\.transitService) var transitService: TransitService
    
    private let threshold: Measurement<UnitLength> = .init(value: 15, unit: .meters)
    private var cancellables: Set<AnyCancellable> = .init()
    
    public init() {
        
    }
    
    public func stationFinder(coordinate: CLLocationCoordinate2D) async {
        
        do {
            let locations = try await transitService.findTransitLocation(
                for: coordinate,
                filtering: .stops,
                maxNumberOfResults: 20
            )
            
            print("TransitLocations")
            print(locations)
        } catch {
            print(error)
        }
        
    }
    
}

