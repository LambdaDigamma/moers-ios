//
//  ITDFootPathInfo.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import Foundation
import XMLCoder

public struct ITDFootPathInfo: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let position: String
    public let duration: Int
    public let dTM: Int
    public let footPathElements: [ITDFootPathElem]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        
        switch key {
            case CodingKeys.position,
                CodingKeys.duration,
                CodingKeys.dTM:
                return .attribute
            default:
                return .element
        }
        
    }
    
    public enum CodingKeys: String, CodingKey {
        case position = "position"
        case duration = "duration"
        case dTM = "dTM"
        case footPathElements = "itdFootPathElem"
    }
    
}

public struct ITDFootPathElem: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let description: String
    public let type: String
    public let lF: Int
    public let lT: Int
    public let level: String
    
    public let points: [ITDFootPathPoint]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.points:
                return .element
            default:
                return .attribute
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case description = "description"
        case type = "type"
        case lF = "lF"
        case lT = "lT"
        case level = "level"
        case points = "itdPoint"
    }
    
}

public struct ITDFootPathPoint: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let stopID: Int
    public let area: String
    public let platform: String?
    public let x: Double
    public let y: Double
    public let mapName: String
    public let georef: String?
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            default:
                return .attribute
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case stopID = "stopID"
        case area
        case platform
        case x
        case y
        case mapName
        case georef
    }
    
}
