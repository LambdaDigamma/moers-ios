//
//  Container+LegacyEventService.swift
//  moers festival
//
//  Created for Factory migration
//

import Foundation
import Factory
import MMEvents

public extension Container {

    var legacyEventService: Factory<LegacyEventService> {
        self {
            nil // Will be configured at runtime
        }
    }

}
