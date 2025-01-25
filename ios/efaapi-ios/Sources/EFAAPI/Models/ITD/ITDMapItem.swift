//
//  ITDMapItem.swift
//  
//
//  Created by Lennart Fischer on 26.07.20.
//

import Foundation
import XMLCoder

public struct ITDMapItem: Codable, DynamicNodeDecoding {
    
    public var text: String
    public var type: String
    
    public enum CodingKeys: String, CodingKey {
        case text
        case type
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
}
