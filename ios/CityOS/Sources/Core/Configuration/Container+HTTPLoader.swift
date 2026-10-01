//
//  Container+HTTPLoader.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import FactoryKit
import ModernNetworking

public extension Container {
    
    @MainActor
    var httpLoader: Factory<HTTPLoader> {
        self {
            // This will be set by NetworkingConfiguration
            fatalError("HTTPLoader must be configured before use")
        }
    }

    @MainActor
    var httpClient: Factory<any HTTPClient> {
        self {
            HTTPLoaderClient(loader: self.httpLoader())
        }
    }
    
}
