//
//  AppDatabase.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import GRDB

/// AppDatabase lets the application access the database.
///
/// It applies the pratices recommended at
/// <https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md>
public struct AppDatabase {
    
    /// Creates an `AppDatabase`, and make sure the database schema is ready.
    public init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, while SwiftUI previews and tests
    /// can use a fast in-memory `DatabaseQueue`.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
    internal let dbWriter: any DatabaseWriter
    
}

// MARK: - Database Access: Reads
// This demo app does not provide any specific reading method, and instead
// gives an unrestricted read-only access to the rest of the application.
// In your app, you are free to choose another path, and define focused
// reading methods.
extension AppDatabase {
    /// Provides a read-only access to the database
    var reader: DatabaseReader {
        dbWriter
    }
}

extension Optional<Int64> {
    
    public func toInt() -> Int? {
        if let self = self {
            return Int(truncatingIfNeeded: self)
        } else {
            return nil
        }
    }
    
}

extension Optional<Int> {
    
    public func toInt64() -> Int64? {
        if let self = self {
            return Int64(truncatingIfNeeded: self)
        } else {
            return nil
        }
    }
    
}

extension Int {
    
    public func toInt64() -> Int64 {
        
        return Int64(truncatingIfNeeded: self)
        
    }
    
}
