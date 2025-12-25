//
//  TripResponse.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import Foundation

import Foundation
import XMLCoder

public struct TripResponse: Codable, DynamicNodeDecoding, BaseModel {
    
    public let language: String
    public let sessionID: String
    public let now: Date
    
    public let tripRequest: TripRequest
    
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
        case tripRequest = "itdTripRequest"
    }
    
}
