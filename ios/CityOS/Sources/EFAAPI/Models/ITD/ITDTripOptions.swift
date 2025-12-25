//
//  ITDTripOptions.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDTripOptions: Codable, DynamicNodeDecoding {
    
    public let userDefined: Bool
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.userDefined:
                return .attribute
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case userDefined = "userDefined"
    }
    
}
