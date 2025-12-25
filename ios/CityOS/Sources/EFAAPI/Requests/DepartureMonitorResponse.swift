//
//  DepartureMonitorResponse.swift
//  
//
//  Created by Lennart Fischer on 18.04.21.
//

import Foundation
import XMLCoder

public struct DepartureMonitorResponse: Codable, DynamicNodeDecoding, BaseModel {
    
    public let language: String
    public let sessionID: Int
    public let now: Date
    
    public let departureMonitorRequest: DepartureMonitorRequest
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.language:
                return .attribute
            case CodingKeys.sessionID:
                return .attribute
            case CodingKeys.now:
                return .attribute
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case language
        case sessionID
        case now
        case departureMonitorRequest = "itdDepartureMonitorRequest"
    }
    
}
