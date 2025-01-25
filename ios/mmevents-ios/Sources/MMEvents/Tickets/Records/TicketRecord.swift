//
//  TicketRecord.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import GRDB

public struct TicketExtras: Codable, Equatable {
    
}

public struct TicketRecord: Equatable, Codable {
    
    public var id: Int64
    public var name: String
    
    public var description: String?
    public var url: String?
    
    public var isActive: Bool
    
    public var extras: TicketExtras?
    
    public var createdAt: Date?
    public var updatedAt: Date?
    public var publishedAt: Date?
    public var archivedAt: Date?
    public var deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case url
        case isActive = "is_active"
        case extras
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case archivedAt = "archived_at"
        case deletedAt = "deleted_at"
    }
    
}

extension TicketRecord: FetchableRecord, MutablePersistableRecord {
    
    public static var databaseTableName: String = TicketTableDefinition.tableName
    
    internal enum Columns {
        static let publishedAt = Column(CodingKeys.publishedAt.rawValue)
    }
    
}
