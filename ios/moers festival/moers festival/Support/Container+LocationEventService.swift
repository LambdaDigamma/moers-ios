//
//  Container+LocationEventService.swift
//  moers festival
//
//  Created for Factory migration
//

import Foundation
import FactoryKit
import Core
import ModernNetworking

public extension Container {
    
    @MainActor
    var locationEventService: Factory<LocationEventService> {
        self {
            DefaultLocationEventService(client: self.httpClient())
        }
        .singleton
    }

}
