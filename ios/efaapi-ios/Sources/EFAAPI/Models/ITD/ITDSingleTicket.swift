//
//  ITDSingleTicket.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDSingleTicket: Codable, DynamicNodeDecoding {
    
    public let net: String
    public let toPR: Int
    public let fromPR: Int
    public let currency: String
    public let unitName: String
    public let fareAdult: String
    public let fareChild: String
    public let unitsAdult: String
    public let unitsBikeChild: String
    public let levelAdult: String
    public let levelChild: String
    public let idAdult: String?
    public let idChild: String?
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            default:
                return .attribute
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case net
        case toPR
        case fromPR
        case currency
        case unitName
        case fareAdult
        case fareChild
        case unitsAdult
        case unitsBikeChild
        case levelAdult
        case levelChild
        case idAdult
        case idChild
    }
    
}
