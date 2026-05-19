//
//  Container+CurrentDateProvider.swift
//  Core
//
//  Created for Factory migration
//

import Factory
import Foundation

public extension Container {
    
    var currentDateProvider: Factory<CurrentDateProviding> {
        self {
            SystemCurrentDateProvider()
        }
        .singleton
    }
    
}
