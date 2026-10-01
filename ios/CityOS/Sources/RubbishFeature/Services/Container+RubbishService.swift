//
//  Container+RubbishService.swift
//  RubbishFeature
//
//  Created for Factory migration
//

import Foundation
import FactoryKit

public extension Container {
    
    @MainActor
    var rubbishService: Factory<RubbishService> {
        self {
            StaticRubbishService()
        }
    }
    
}
