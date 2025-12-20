//
//  TicketOptionRecord.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import GRDB

public struct TicketOptionRecord: Equatable, Codable {
    
    public var id: Int64
    public var name: String
    public var price: Double?
    
    public var ticketID: Int64
    public var extras: TicketExtras?
    
    public var createdAt: Date?
    public var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case ticketID = "ticket_id"
        case extras
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
}

extension TicketOptionRecord: FetchableRecord, MutablePersistableRecord {
    
    public static var databaseTableName: String = TicketOptionTableDefinition.tableName
    
    public enum Columns {
        static let createdAt = Column(CodingKeys.createdAt.rawValue)
        static let updatedAt = Column(CodingKeys.updatedAt.rawValue)
    }
    
}
