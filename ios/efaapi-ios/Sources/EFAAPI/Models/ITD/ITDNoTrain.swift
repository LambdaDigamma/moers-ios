//
//  ITDNoTrain.swift
//  
//
//  Created by Lennart Fischer on 08.12.21.
//

import Foundation
import XMLCoder

public struct ITDNoTrain: Codable, Equatable, DynamicNodeDecoding {
    
    public let name: String
    public let fullName: String?
    public let delay: Int?
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name, CodingKeys.delay:
                return .attribute
            case CodingKeys.fullName:
                return .element
            default:
                return .elementOrAttribute
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case name = "name"
        case delay = "delay"
        case fullName = "fullName"
    }
    
}
