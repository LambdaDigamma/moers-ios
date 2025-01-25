//
//  CachedEFAStation+Extensions.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation
import Core

public extension CachedEFAStation {
    
    static func from(transitLocation: TransitLocation) -> CachedEFAStation {
        return CachedEFAStation(
            id: transitLocation.statelessIdentifier,
            name: transitLocation.name,
            coordinates: transitLocation.coordinates?.toPoint()
        )
    }
    
    static func from(assignedStop: ITDOdvAssignedStop) -> CachedEFAStation {
        return CachedEFAStation(
            id: assignedStop.value,
            name: assignedStop.nameWithPlace
        )
    }
    
}
