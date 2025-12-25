//
//  ITDItinerary.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDItinerary: Codable, DynamicNodeDecoding {
    
    public let routeList: ITDRouteList?
    
    public var safeRoutes: [ITDRoute] {
        return routeList?.routes ?? []
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.routeList:
                return .element
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case routeList = "itdRouteList"
    }
    
}
