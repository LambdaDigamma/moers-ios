//
//  Container+LocationEventService.swift
//  moers festival
//
//  Created for Factory migration
//

import Foundation
import Factory
import ModernNetworking

public extension Container {

    var locationEventService: Factory<LocationEventService> {
        self {
            DefaultLocationEventService(loader: self.httpLoader())
        }
        .singleton
    }

}
