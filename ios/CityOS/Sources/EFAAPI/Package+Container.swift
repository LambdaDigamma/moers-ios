//
//  Package+Container.swift
//  
//
//  Created by Lennart Fischer on 25.12.22.
//

import Foundation
import Factory

public extension Container {
    
    var transitService: Factory<TransitService> {
        self {
            let service = StaticTransitService()
            
            service.loadStations = {
                return [
                    .init(name: "Musterstraße", description: "Musterstadt"),
                    .init(name: "Nachtigalweg", description: "Musterstadt"),
                ]
            }
            
            return service as TransitService
        }
            .singleton
    }
    
    
    var tripService: Factory<DefaultTripService> {
        self {
            let service = DefaultTripService()
            
            return service
        }
        .singleton
    }
    
}

