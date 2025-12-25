//
//  StopFinderResponse.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public class StopFinderResponse: Codable, DynamicNodeDecoding, BaseModel {
    
    public let language: String
    public let sessionID: Int
    public let now: Date
    
    public let stopFinderRequest: StopFinderRequest
    
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
        case stopFinderRequest = "itdStopFinderRequest"
    }
    
}
