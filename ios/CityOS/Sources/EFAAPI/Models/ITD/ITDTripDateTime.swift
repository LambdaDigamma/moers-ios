//
//  ITDTripDateTime.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

nonisolated public struct ITDTripDateTime: Codable, Equatable, Hashable, Sendable, DynamicNodeDecoding {
    
    public let depArrType: DepArrType
    public let dateTime: ITDDateTime
    public let dateRange: ITDDateRange
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.depArrType:
                return .attribute
            default:
                return .element
        }
    }
    
    public enum DepArrType: String, Codable, Sendable {
        case departure = "dep"
        case arrival = "arr"
        
        public var localized: String {
            switch self {
                case .arrival:
                    return String(localized: "Arrival", bundle: .module)
                case .departure:
                    return String(localized: "Departure", bundle: .module)
            }
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case depArrType = "deparr"
        case dateTime = "itdDateTime"
        case dateRange = "itdDateRange"
    }
    
}
