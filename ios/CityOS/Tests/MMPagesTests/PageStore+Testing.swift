//
//  PageStore+Testing.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import Foundation
import GRDB
@testable import MMPages

internal extension PageStore {
    
    static func inMemory() -> (store: PageStore, writer: DatabaseWriter) {
        
        guard let dbQueue = try? DatabaseQueue(path: ":memory:") else { fatalError() }
        
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("migrate") { db in
            
            try db.create(table: "pages", body: { (tableDefinition: TableDefinition) in
                PageTableDefinition.apply(tableDefinition)
            })
            
            try db.create(table: "page_blocks", body: { (tableDefinition: TableDefinition) in
                PageBlockTableDefinition.apply(tableDefinition)
            })
            
        }
        
        try? migrator.migrate(dbQueue)
        
        return (PageStore(writer: dbQueue, reader: dbQueue), dbQueue)
        
    }
    
}
