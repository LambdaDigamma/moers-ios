//
//  TicketAssignmentRecord.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import GRDB

public struct TicketAssignmentRecord: Codable, Equatable {
    
    public var id: Int64
    public var ticketID: Int64
    public var eventID: Int64
    
    public var createdAt: Date?
    public var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ticketID = "ticket_id"
        case eventID = "event_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
}

extension TicketAssignmentRecord: FetchableRecord, MutablePersistableRecord {
    
    public static var databaseTableName: String = TicketAssignmentTableDefinition.tableName
    
    public enum Columns {
        static let createdAt = Column(CodingKeys.createdAt.rawValue)
        static let updatedAt = Column(CodingKeys.updatedAt.rawValue)
    }
    
}
