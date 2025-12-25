//
//  ITDRouteList.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDRouteList: Codable, DynamicNodeDecoding {
    
    public let routes: [ITDRoute]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.routes:
                return .element
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case routes = "itdRoute"
    }
    
}
