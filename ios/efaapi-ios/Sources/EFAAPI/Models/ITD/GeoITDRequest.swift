//
//  GeoITDRequest.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import XMLCoder
import ModernNetworking

public struct GeoITDRequest: Model, DynamicNodeDecoding {
    
    public let language: String
    public let sessionID: Int
    public let now: Date
    public let geoObjectRequest: ITDGeoObjectRequest
    
    enum CodingKeys: String, CodingKey {
        case language
        case sessionID
        case now
        case geoObjectRequest = "itdGeoObjectRequest"
    }
    
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
    
}
