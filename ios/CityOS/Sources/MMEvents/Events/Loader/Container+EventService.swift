//
//  Container+EventService.swift
//  MMEvents
//
//  Created for Factory migration
//

import Foundation
import FactoryKit

public extension Container {
    
    @MainActor
    var eventService: Factory<EventService?> {
        self {
            nil // Will be configured at runtime
        }
    }
    
}
