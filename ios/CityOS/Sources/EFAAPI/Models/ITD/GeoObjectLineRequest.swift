//
//  GeoObjectLineRequest.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import XMLCoder

public struct GeoObjectLineRequest: Codable, DynamicNodeDecoding {
    
    public let servingLines: ITDServingLines
    
    enum CodingKeys: String, CodingKey {
        case servingLines = "itdServingLines"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.servingLines:
                return .element
            default:
                return .element
        }
    }
    
}
