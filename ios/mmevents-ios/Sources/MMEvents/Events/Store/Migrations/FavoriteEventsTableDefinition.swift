//
//  FavoriteEventsTableDefinition.swift
//  
//
//  Created by Lennart Fischer on 28.04.23.
//

import Foundation
import GRDB

public struct FavoriteEventsTableDefinition: ApplyTableDefinition {
    
    public static let tableName = "favorite_events"
    
    public static func apply(to t: TableDefinition) {
        
        t.autoIncrementedPrimaryKey("id", onConflict: .replace)
        
        t.column("event_id")
            .unique(onConflict: .replace)
            .notNull()
        
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        
    }
    
    public var tableName: String = Self.tableName
    
    public func apply(to t: TableDefinition) {
        Self.apply(to: t)
    }
    
}

