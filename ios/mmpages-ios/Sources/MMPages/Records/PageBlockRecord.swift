//
//  PageBlockRecord.swift
//  
//
//  Created by Lennart Fischer on 04.04.23.
//

import Foundation
import MediaLibraryKit
import GRDB

public struct PageBlockRecord: Equatable {
    
    public var id: Int64?
    
    public var pageID: Int64?
    public var type: BlockType
    
    public var data: AnyBlockable
    public var parentID: Int64?
    public var slot: String?
    public var order: Int64?
    
    public var createdAt: Date?
    public var updatedAt: Date?
    public var publishedAt: Date?
    public var archivedAt: Date?
    public var expiredAt: Date?
    public var hiddenAt: Date?
    public var deletedAt: Date?
    
    public var mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer()
    
    public static func == (lhs: PageBlockRecord, rhs: PageBlockRecord) -> Bool {
        return
            lhs.id == rhs.id
        && lhs.pageID == rhs.pageID
//        && lhs.data == rhs.data
        && lhs.parentID == rhs.parentID
        && lhs.slot == rhs.slot
        && lhs.order == rhs.order
        && lhs.createdAt == rhs.createdAt
        && lhs.updatedAt == rhs.updatedAt
        && lhs.publishedAt == rhs.publishedAt
        && lhs.archivedAt == rhs.archivedAt
        && lhs.expiredAt == rhs.expiredAt
        && lhs.hiddenAt == rhs.hiddenAt
        && lhs.deletedAt == rhs.deletedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case pageID = "page_id"
        case type
        case data
        case parentID = "parent_id"
        case slot
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case archivedAt = "archived_at"
        case expiredAt = "expired_at"
        case hiddenAt = "hidden_at"
        case deletedAt = "deleted_at"
        case mediaCollections = "media_collections"
    }
    
}

extension PageBlockRecord: Codable, FetchableRecord, MutablePersistableRecord {
    
    public static var databaseTableName: String = PageBlockTableDefinition.tableName
    
    internal enum Columns {
        static let pageID = Column("page_id")
        static let order = Column("order")
        static let publishedAt = Column("published_at")
    }
    
}

extension PageBlock {
    
    public func toRecord() -> PageBlockRecord {
        
        // Todo: Fix this
        
        return PageBlockRecord(
            id: self.id.toInt64(),
            pageID: self.pageID?.toInt64(),
            type: self.blockType,
            data: self.data,
            parentID: nil,
            slot: nil,
            order: nil,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            publishedAt: self.createdAt,
archivedAt: nil,
            expiredAt: nil,
            hiddenAt: nil,
            deletedAt: nil,
            mediaCollections: self.mediaCollectionsContainer ?? .init()
        )
        
    }
    
}

extension PageBlockRecord {
    
    public func toBase() -> PageBlock {
        
        return PageBlock(
            id: self.id.toInt() ?? -1,
            pageID: self.pageID.toInt() ?? -1,
            blockType: self.type,
            data: self.data,
            children: [],
            mediaCollectionsContainer: self.mediaCollections,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
        
    }
    
}
