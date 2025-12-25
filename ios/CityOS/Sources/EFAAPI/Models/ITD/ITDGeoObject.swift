//
//  ITDGeoObject.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import XMLCoder

public struct ITDGeoObject: Codable, DynamicNodeDecoding {
    
    public let geoObjectLineRequest: GeoObjectLineRequest
    public let geoObjectLineResponse: GeoObjectLineResponse
    
    enum CodingKeys: String, CodingKey {
        case geoObjectLineRequest = "geoObjectLineRequest"
        case geoObjectLineResponse = "geoObjectLineResponse"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.geoObjectLineRequest:
                return .element
            case CodingKeys.geoObjectLineResponse:
                return .element
            default:
                return .element
        }
    }
    
}

