//
//  Audit.swift
//  
//
//  Created by Lennart Fischer on 01.01.20.
//

import Foundation

public struct Audit: Codable {
    
    public let id: Int
    public let event: EventType
    public let oldValues: AuditValues
    public let newValues: AuditValues
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public enum EventType: String, Codable {
        case created = "created"
        case updated = "updated"
        case deleted = "deleted"
        case restored = "restored"
    }
    
    public struct AuditValues: Codable {
        
        public var baseValues: [String: AuditGenericValue?]
        
        public init(from decoder: Decoder) throws {
    
            let container = try decoder.singleValueContainer()
            
            do {
                baseValues = try container.decode([String: AuditGenericValue?].self)
            } catch DecodingError.typeMismatch {
                baseValues = [:]
            }
            
        }
        
    }
    
}
