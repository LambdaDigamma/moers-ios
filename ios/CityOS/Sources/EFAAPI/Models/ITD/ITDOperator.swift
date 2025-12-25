//
//  ITDOperator.swift
//  
//
//  Created by Lennart Fischer on 19.04.21.
//

import Foundation
import XMLCoder

public struct ITDOperator: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let code: String
    public let name: String
    public let publicCode: String
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.code, CodingKeys.name, CodingKeys.publicCode:
                return .element
            default:
                return .elementOrAttribute
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
        case publicCode = "publicCode"
    }
    
}
