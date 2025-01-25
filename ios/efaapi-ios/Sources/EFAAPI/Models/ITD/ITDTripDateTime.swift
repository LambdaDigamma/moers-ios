//
//  ITDTripDateTime.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDTripDateTime: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
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
    
    public enum DepArrType: String, Codable {
        case departure = "dep"
        case arrival = "arr"
        
        public var localized: String {
            switch self {
                case .arrival:
                    return "Ankunft"
                case .departure:
                    return "Abfahrt"
            }
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case depArrType = "deparr"
        case dateTime = "itdDateTime"
        case dateRange = "itdDateRange"
    }
    
}
