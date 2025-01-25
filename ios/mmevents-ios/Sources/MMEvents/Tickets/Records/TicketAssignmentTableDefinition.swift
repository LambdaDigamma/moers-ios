//
//  TicketAssignmentTableDefinition.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import GRDB

public enum TicketAssignmentTableDefinition {
    
    public static let tableName = "ticket_assignments"
    
    public static func apply(to t: TableDefinition) {
        
        t.column("id", .integer)
            .notNull(onConflict: .replace)
            .primaryKey(onConflict: .replace)
            .unique(onConflict: .replace)
        
        t.column("ticket_id", .integer).notNull()
        t.column("event_id", .integer).notNull()
        
        t.uniqueKey(["ticket_id", "event_id"])
        
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        
    }
    
}

