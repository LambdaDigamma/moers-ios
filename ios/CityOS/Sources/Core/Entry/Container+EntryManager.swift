//
//  Container+EntryManager.swift
//  Core
//
//  Created for Factory migration
//

import Foundation
import FactoryKit
import ModernNetworking

public extension Container {
    
    @MainActor
    var entryManager: Factory<EntryManagerProtocol> {
        self {
            EntryManager(client: self.httpClient())
        }
        .singleton
    }
    
}
