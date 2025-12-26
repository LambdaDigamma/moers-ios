//
//  Container+EntryManager.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import Factory
import ModernNetworking

public extension Container {
    
    var entryManager: Factory<EntryManagerProtocol> {
        self {
            EntryManager(loader: self.httpLoader())
        }
        .singleton
    }
    
}
