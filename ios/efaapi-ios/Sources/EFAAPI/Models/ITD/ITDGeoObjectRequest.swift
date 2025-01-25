//
//  ITDGeoObjectRequest.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import XMLCoder

public struct ITDGeoObjectRequest: Codable, DynamicNodeDecoding {
    
    public let requestID: Int
    public let geoObject: ITDGeoObject
    
    enum CodingKeys: String, CodingKey {
        case requestID = "requestID"
        case geoObject = "itdGeoObject"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.requestID:
                return .attribute
            case CodingKeys.geoObject:
                return .element
            default:
                return .element
        }
    }
    
}
