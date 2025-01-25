//
//  DB+Definition.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import GRDB

public enum PageBlockTableDefinition {
    
    public static let tableName = "page_blocks"
    
    public static func apply(_ t: TableDefinition) {
        
        t.column("id", .integer)
            .notNull(onConflict: .replace)
            .primaryKey(onConflict: .replace)
            .unique(onConflict: .replace)
        
        t.column("page_id").notNull()
        t.column("type", .text).notNull()
        t.column("data", .text)
        t.column("parent_id", .integer)
        t.column("slot", .text)
        t.column("order", .integer)
        
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        t.column("published_at", .datetime)
        t.column("archived_at", .datetime)
        t.column("expired_at", .datetime)
        t.column("hidden_at", .datetime)
        t.column("deleted_at", .datetime)
        
        t.column("media_collections", .text)
        
    }
    
}

public enum PageTableDefinition {
    
    public static let tableName = "pages"
    
    public static func apply(_ t: TableDefinition) {
        
        t.column("id", .integer)
            .notNull(onConflict: .replace)
            .primaryKey(onConflict: .replace)
            .unique(onConflict: .replace)
        
        t.column("title", .text).notNull()
        t.column("slug", .text)
        t.column("summary", .text)
        t.column("keywords", .text)
        t.column("parent_menu_item_id", .integer)
        t.column("page_template_id", .integer)
        t.column("extras", .text)
        
        t.column("published_at", .datetime)
        t.column("archived_at", .datetime)
        t.column("created_at", .datetime)
        t.column("updated_at", .datetime)
        t.column("deleted_at", .datetime)
        
        t.column("media_collections", .text)
        
    }
    
}
