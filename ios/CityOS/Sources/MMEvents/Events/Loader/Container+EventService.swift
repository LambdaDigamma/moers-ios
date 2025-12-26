//
//  Container+EventService.swift
//  MMEvents
//
//  Created for Factory migration
//

import Foundation
import Factory

public extension Container {
    
    var eventService: Factory<EventService?> {
        self {
            nil // Will be configured at runtime
        }
    }
    
}
