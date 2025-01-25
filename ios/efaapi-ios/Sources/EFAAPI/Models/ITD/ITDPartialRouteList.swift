//
//  ITDPartialRouteList.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDPartialRouteList: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let partialRoutes: [ITDPartialRoute]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.partialRoutes:
                return .element
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case partialRoutes = "itdPartialRoute"
    }
    
}



