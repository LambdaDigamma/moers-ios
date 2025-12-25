//
//  EventStore+Testing.swift
//  
//
//  Created by Lennart Fischer on 17.04.23.
//

import Foundation
import GRDB
@testable import MMEvents

internal extension EventStore {
    
    static func inMemory() -> (store: EventStore, writer: DatabaseWriter) {
        
        let dbQueue = MemoryDatabase.default()
        
        return (EventStore(writer: dbQueue, reader: dbQueue), dbQueue)
        
    }
    
}
