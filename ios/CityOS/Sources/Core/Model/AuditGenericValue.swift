//
//  AuditGenericValue.swift
//  
//
//  Created by Lennart Fischer on 01.01.20.
//

import Foundation

public enum AuditGenericValue: Codable {
    
    case string(String), integer(Int), double(Double)

    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        do {
            let stringValue = try container.decode(String.self)
            self = .string(stringValue)
        } catch DecodingError.typeMismatch {
            let integerValue = try? container.decode(Int.self)
            
            if let integerValue = integerValue {
                self = .integer(integerValue)
            } else {
                let doubleValue = try? container.decode(Double.self)
                self = .double(doubleValue ?? 0)
            }
            
        }
        
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .string(let stringValue): try container.encode(stringValue)
            case .integer(let integerValue): try container.encode(integerValue)
            case .double(let doubleValue): try container.encode(doubleValue)
        }
    }
    
}
