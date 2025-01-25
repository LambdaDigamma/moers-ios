//
//  ITDDMDateTime.swift
//  
//
//  Created by Lennart Fischer on 18.04.21.
//

import Foundation
import XMLCoder

public struct ITDDMDateTime: Codable, DynamicNodeDecoding {
    
    /// `deparr`
    var mode: String?
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.mode:
                return .attribute
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case mode = "deparr"
    }
    
}
