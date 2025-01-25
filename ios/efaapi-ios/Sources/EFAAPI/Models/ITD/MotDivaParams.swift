//
//  MotDivaParams.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct MotDivaParams: Codable, Equatable, Hashable, DynamicNodeDecoding, LineIdentifiable {
    
    public let line: String
    public let project: String
    public let direction: String
    public let supplement: String
    public let network: String
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            default:
                return .attribute
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case line
        case project
        case direction
        case supplement
        case network
    }
    
    public var lineIdentifier: String {
        return "\(network):\(line):\(supplement):\(direction):\(project)"
    }
    
}
