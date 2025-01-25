//
//  ODVNameInput.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public struct ODVNameInput: Codable, DynamicNodeDecoding {
    
    public var name: String
    
    public enum CodingKeys: String, CodingKey {
        case name = ""
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name:
                return .element
            default:
                return .attribute
        }
    }
    
}
