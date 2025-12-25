//
//  StopFinderRequest.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public struct StopFinderRequest: Codable, DynamicNodeDecoding {
    
    public let requestID: Int
    public let odv: ODV
    public var dateTime: ITDDateTime
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.requestID:
                return .attribute
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case requestID = "requestID"
        case odv = "itdOdv"
        case dateTime = "itdDateTime"
    }
    
}
