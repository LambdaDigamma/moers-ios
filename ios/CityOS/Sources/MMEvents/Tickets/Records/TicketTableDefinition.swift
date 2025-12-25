//
//  TicketTableDefinition.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import GRDB

public enum TicketTableDefinition {
    
    public static let tableName = "tickets"
    
    public static func apply(to t: TableDefinition) {
        
        t.column("id", .integer)
            .notNull(onConflict: .replace)
            .primaryKey(onConflict: .replace)
            .unique(onConflict: .replace)
        
        t.column("name", .text).notNull()
        t.column("description", .text)
        t.column("url", .text)
        t.column("is_active", .boolean)
        t.column("extras", .text)
        
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        t.column("published_at", .datetime)
        t.column("archived_at", .datetime)
        t.column("deleted_at", .datetime)
        
    }
    
}
