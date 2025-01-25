//
//  MemoryDatabase.swift
//  
//
//  Created by Lennart Fischer on 29.04.23.
//

import Foundation
import GRDB
@testable import MMEvents

public class MemoryDatabase {
    
    private var definitions: [ApplyTableDefinition]
    
    public init(definitions: [ApplyTableDefinition]) {
        
        self.definitions = definitions
        
    }
    
    public func create() -> DatabaseQueue {
        
        guard let dbQueue = try? DatabaseQueue(path: ":memory:") else { fatalError() }
        
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("migrate") { db in
            
            for definition in self.definitions {
                
                try db.create(table: definition.tableName, body: { tableDefinition in
                    definition.apply(to: tableDefinition)
                })
                
            }
            
        }
        
        try? migrator.migrate(dbQueue)
        
        return dbQueue
        
    }
    
    public static func `default`() -> DatabaseQueue {
        
        return MemoryDatabase(definitions: [
            PlaceTableDefinition(),
            EventTableDefinition(),
            FavoriteEventsTableDefinition()
        ]).create()
        
    }
    
}
