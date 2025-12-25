//
//  PlaceTableDefinition.swift
//  
//
//  Created by Lennart Fischer on 17.04.23.
//

import Foundation
import GRDB

public struct PlaceTableDefinition: ApplyTableDefinition {
    
    public static let tableName = "places"
    
    public static func apply(to t: TableDefinition) {
        
        t.column("id", .integer)
            .notNull(onConflict: .replace)
            .primaryKey(onConflict: .replace)
            .unique(onConflict: .replace)
        t.column("name", .text).notNull()
        t.column("latitude", .double).notNull()
        t.column("longitude", .double).notNull()
        t.column("street_name", .text)
        t.column("street_number", .text)
        t.column("street_addition", .text)
        t.column("postal_code", .text)
        t.column("postal_town", .text)
        t.column("country_code", .text)
        t.column("page_id", .integer)
        t.column("validated_at", .datetime)
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        t.column("deleted_at", .datetime)
        
    }
    
    public var tableName: String = Self.tableName
    
    public func apply(to t: TableDefinition) {
        Self.apply(to: t)
    }
    
}
