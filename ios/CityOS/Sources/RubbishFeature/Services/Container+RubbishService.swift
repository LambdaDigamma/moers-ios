//
//  Container+RubbishService.swift
//  RubbishFeature
//
//  Created for Factory migration
//

import Foundation
import Factory

public extension Container {
    
    var rubbishService: Factory<RubbishService> {
        self {
            StaticRubbishService()
        }
    }
    
}
