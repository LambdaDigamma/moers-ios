//
//  ITDPathCoordinates.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import XMLCoder

public struct ITDPathCoordinates: Codable, DynamicNodeDecoding {
    
    public let coordinateBaseElemList: ITDCoordinateBaseElemList
    
    enum CodingKeys: String, CodingKey {
        case coordinateBaseElemList = "itdCoordinateBaseElemList"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.coordinateBaseElemList:
                return .element
            default:
                return .element
        }
    }
    
}

public struct ITDCoordinateBaseElemList: Codable, DynamicNodeDecoding {
    
    public let coordinates: [ITDCoordinateBaseElem]
    
    enum CodingKeys: String, CodingKey {
        case coordinates = "itdCoordinateBaseElem"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.coordinates:
                return .element
            default:
                return .element
        }
    }
    
}

public struct ITDCoordinateBaseElem: Codable, DynamicNodeDecoding {
    
    public let x: Double
    public let y: Double
    
    enum CodingKeys: String, CodingKey {
        case x = "x"
        case y = "y"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.x:
                return .element
            case CodingKeys.y:
                return .element
            default:
                return .element
        }
    }
    
}


