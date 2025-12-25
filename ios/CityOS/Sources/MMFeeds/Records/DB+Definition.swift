//
//  DB+Definition.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import GRDB

public enum PostTableDefinition {
    
    public static let tableName = "posts"
    
    public static func apply(_ t: TableDefinition) {
        
        t.column("id", .integer)
            .notNull(onConflict: .replace)
            .primaryKey(onConflict: .replace)
            .unique(onConflict: .replace)
        
        t.column("title", .text).notNull()
        t.column("summary", .text).notNull()
        t.column("feed_id", .integer)
        t.column("page_id", .integer)
        
        t.column("vimeo_id", .text)
        t.column("publication", .text)
        t.column("external_href", .text)
        t.column("extras", .text)
        t.column("media_collections", .text)
        t.column("published_at", .datetime)
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        t.column("deleted_at", .datetime)
        
    }
    
}
