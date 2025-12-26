//
//  ITDInfoTextList.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDInfoTextList: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let elements: [InfoTextListElement]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case elements = "infoTextListElem"
    }
    
}

public struct InfoTextListElement: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let code: String?
    public let type: String
    public let content: String
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.code, CodingKeys.type:
                return .attribute
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case type = "type"
        case content = ""
    }
    
}


