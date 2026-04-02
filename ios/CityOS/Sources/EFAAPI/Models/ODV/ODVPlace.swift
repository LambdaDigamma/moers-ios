//
//  ODVPlace.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public struct ODVPlace: Codable, Sendable, DynamicNodeDecoding {
    
    public var state: String
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.state:
                return .attribute
            default:
                return .element
        }
    }
    
}
