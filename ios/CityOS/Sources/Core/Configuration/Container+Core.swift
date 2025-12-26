//
//  Container+Core.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import Factory
import ModernNetworking

public extension Container {
    
    // MARK: - Networking
    
    var httpLoader: Factory<HTTPLoader> {
        self {
            // This will be set by NetworkingConfiguration
            fatalError("HTTPLoader must be configured before use")
        }
    }
    
    // MARK: - Location Services
    
    var locationService: Factory<LocationService> {
        self {
            DefaultLocationService()
        }
        .singleton
    }
    
    var locationManager: Factory<LocationManagerProtocol> {
        self {
            LocationManager()
        }
        .singleton
    }
    
    // MARK: - Core Services
    
    var entryManager: Factory<EntryManagerProtocol> {
        self {
            EntryManager(loader: self.httpLoader())
        }
        .singleton
    }
    
    var cameraManager: Factory<CameraManagerProtocol> {
        self {
            CameraManager()
        }
        .singleton
    }
    
}
