//
//  File.swift
//  
//
//  Created by Lennart Fischer on 24.05.23.
//

import Foundation

import Foundation
import GRDB

public struct EventAddExtras: ApplyTableDefinition {
    
    public static let tableName = "events"
    
    public static func apply(to t: TableDefinition) {
        
        t.column("extras", .text)
        
    }
    
    public var tableName: String = Self.tableName
    
    public func apply(to t: TableDefinition) {
        Self.apply(to: t)
    }
    
}

