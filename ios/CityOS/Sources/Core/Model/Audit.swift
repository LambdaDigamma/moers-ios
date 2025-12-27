//
//  Audit.swift
//  
//
//  Created by Lennart Fischer on 01.01.20.
//

import Foundation

public struct Audit: Codable, Hashable {
    
    public let id: Int
    public let event: EventType
    public let oldValues: AuditValues
    public let newValues: AuditValues
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Audit, rhs: Audit) -> Bool {
        return lhs.id == rhs.id
    }
    
    public enum EventType: String, Codable {
        case created = "created"
        case updated = "updated"
        case deleted = "deleted"
        case restored = "restored"
    }
    
    public struct AuditValues: Codable, Hashable {
        
        public var baseValues: [String: AuditGenericValue?]
        
        public init(from decoder: Decoder) throws {
    
            let container = try decoder.singleValueContainer()
            
            do {
                baseValues = try container.decode([String: AuditGenericValue?].self)
            } catch DecodingError.typeMismatch {
                baseValues = [:]
            }
            
        }
        
        public func hash(into hasher: inout Hasher) {
            // Hash the keys and values in a consistent order
            let sortedKeys = baseValues.keys.sorted()
            for key in sortedKeys {
                hasher.combine(key)
                if let value = baseValues[key] {
                    hasher.combine(value)
                }
            }
        }
        
        public static func == (lhs: AuditValues, rhs: AuditValues) -> Bool {
            // Compare dictionary contents properly
            guard lhs.baseValues.count == rhs.baseValues.count else {
                return false
            }
            
            for (key, lhsValue) in lhs.baseValues {
                guard let rhsValue = rhs.baseValues[key] else {
                    return false
                }
                // Compare optional values
                switch (lhsValue, rhsValue) {
                case (.none, .none):
                    continue
                case (.some(let lv), .some(let rv)):
                    if lv != rv {
                        return false
                    }
                default:
                    return false
                }
            }
            
            return true
        }
        
    }
    
}
