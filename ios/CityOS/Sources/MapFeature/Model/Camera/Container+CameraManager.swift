//
//  Container+CameraManager.swift
//  MapFeature
//
//  Created for Factory migration
//

import Foundation
import FactoryKit

public extension Container {
    
    @MainActor
    var cameraManager: Factory<CameraManagerProtocol> {
        self {
            CameraManager()
        }
        .singleton
    }
    
}
