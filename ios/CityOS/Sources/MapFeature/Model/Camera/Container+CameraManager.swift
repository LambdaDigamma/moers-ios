//
//  Container+CameraManager.swift
//  MapFeature
//
//  Created for Factory migration
//

import Foundation
import Factory

public extension Container {
    
    var cameraManager: Factory<CameraManagerProtocol> {
        self {
            CameraManager()
        }
        .singleton
    }
    
}
