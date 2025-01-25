//
//  PageRecord.swift
//  
//
//  Created by Lennart Fischer on 04.04.23.
//

import Foundation
import MediaLibraryKit
import GRDB

public struct PageRecord: Equatable {
    
    public var id: Int64?
    
    public var title: String
    public var slug: String?
    public var summary: String?
    public var keywords: [String]
    public var parentMenuItemID: Int64?
    public var pageTemplateID: Int64?
    
    public var createdAt: Date?
    public var updatedAt: Date?
    public var publishedAt: Date?
    public var archivedAt: Date?
    public var deletedAt: Date?
    
    public var mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer()
    
}

extension PageRecord: Codable, FetchableRecord, MutablePersistableRecord {
    
    public static var databaseTableName: String = PageTableDefinition.tableName
    
    public static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy = .convertFromSnakeCase
    public static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy = .convertToSnakeCase
    
    internal enum Columns {
        static let publishedAt = Column("published_at")
    }
    
}

extension Page {
    
    public func toRecord() -> PageRecord {
        
        return PageRecord(
            id: self.id.toInt64(),
            title: self.title ?? "",
            slug: self.slug,
            summary: self.summary,
            keywords: [],
            parentMenuItemID: nil,
            pageTemplateID: self.pageTemplateID?.toInt64(),
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            publishedAt: self.createdAt,
            archivedAt: nil,
            deletedAt: nil,
            mediaCollections: self.mediaCollections
        )
        
    }
    
}

extension PageRecord {
    
    public func toBase() -> Page {
        
        return Page(
            id: self.id.toInt() ?? -1,
            title: self.title,
            slug: self.slug,
            summary: self.summary,
            pageTemplateID: self.pageTemplateID.toInt(),
            creatorID: nil,
            extras: nil,
            mediaCollections: self.mediaCollections,
            archivedAt: self.archivedAt,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
        
    }
    
}
