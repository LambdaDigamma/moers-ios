//
//  AppDatabase+Migrator.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import GRDB
import MMFeeds
import MMPages
import MMEvents

public extension AppDatabase {
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
    internal var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
//#if DEBUG
//        // Speed up development by nuking the database when migrations change
//        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
//        migrator.eraseDatabaseOnSchemaChange = true
//#endif
        
        migrator.registerMigration("createEvents") { db in
            // Create a table
            // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseschema>
            
            try db.create(table: PlaceTableDefinition.tableName) { tableDefinition in
                PlaceTableDefinition.apply(to: tableDefinition)
            }
            
            try db.create(table: PostTableDefinition.tableName, body: { (tableDefinition: TableDefinition) in
                PostTableDefinition.apply(tableDefinition)
            })
            
            try db.create(table: PageTableDefinition.tableName, body: { (tableDefinition: TableDefinition) in
                PageTableDefinition.apply(tableDefinition)
            })
            
            try db.create(table: PageBlockTableDefinition.tableName, body: { (tableDefinition: TableDefinition) in
                PageBlockTableDefinition.apply(tableDefinition)
            })
            
            try db.create(table: EventTableDefinition.tableName, body: { (tableDefinition: TableDefinition) in
                EventTableDefinition.apply(to: tableDefinition)
            })
            
            try db.create(table: FavoriteEventsTableDefinition.tableName, body: { (tableDefinition: TableDefinition) in
                FavoriteEventsTableDefinition.apply(to: tableDefinition)
            })
            
            try db.create(table: TicketTableDefinition.tableName, body: { (tableDefinition: TableDefinition) in
                TicketTableDefinition.apply(to: tableDefinition)
            })
            
            try db.create(table: TicketOptionTableDefinition.tableName, body: { (tableDefinition: TableDefinition) in
                TicketOptionTableDefinition.apply(to: tableDefinition)
            })
            
            try db.create(table: TicketAssignmentTableDefinition.tableName, body: { (tableDefinition: TableDefinition) in
                TicketAssignmentTableDefinition.apply(to: tableDefinition)
            })
            
        }
        
        migrator.registerMigration("events_add_extras") { db in
             
            try db.alter(table: EventTableDefinition.tableName) { t in
                t.add(column: "extras", .text)
            }
            
        }
        
        return migrator
    }
    
}
