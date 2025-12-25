//
//  TicketOptionTableDefinition.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import GRDB

public enum TicketOptionTableDefinition {
    
    public static let tableName = "ticket_options"
    
    public static func apply(to t: TableDefinition) {
        
        t.column("id", .integer)
            .notNull(onConflict: .replace)
            .primaryKey(onConflict: .replace)
            .unique(onConflict: .replace)
        
        t.column("name", .text).notNull()
        t.column("price", .numeric)
        t.column("ticket_id", .integer).notNull()
        t.column("extras", .text)
        
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        
    }
    
}
