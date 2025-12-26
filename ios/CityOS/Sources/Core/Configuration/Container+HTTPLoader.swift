//
//  Container+HTTPLoader.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import Factory
import ModernNetworking

public extension Container {
    
    var httpLoader: Factory<HTTPLoader> {
        self {
            // This will be set by NetworkingConfiguration
            fatalError("HTTPLoader must be configured before use")
        }
    }
    
}
