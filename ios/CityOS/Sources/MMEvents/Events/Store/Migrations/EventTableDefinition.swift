//
//  EventTableDefinition.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import GRDB

public struct EventTableDefinition: ApplyTableDefinition {
    
    public static let tableName = "events"
    
    public static func apply(to t: TableDefinition) {
        
        t.column("id", .integer)
            .notNull(onConflict: .replace)
            .primaryKey(onConflict: .replace)
            .unique(onConflict: .replace)
        
        t.column("name", .text).notNull()
        t.column("start_date", .datetime)
        t.column("end_date", .datetime)
        t.column("description", .text)
        t.column("page_id", .integer)
        t.column("url", .text)
        
        t.column("category", .text)
        
        t.column("organisation_id", .integer)
        t.column("place_id", .integer)
        
        t.column("published_at", .datetime)
        t.column("cancelled_at", .datetime)
        t.column("scheduled_at", .datetime)
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        t.column("archived_at", .datetime)
        t.column("deleted_at", .datetime)
        
        t.column("artists", .text)
        t.column("media_collections", .text)
        
    }
    
    public var tableName: String = Self.tableName
    
    public func apply(to t: TableDefinition) {
        Self.apply(to: t)
    }
    
}
