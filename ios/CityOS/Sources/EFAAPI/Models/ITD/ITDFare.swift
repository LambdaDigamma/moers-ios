//
//  ITDFare.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDFare: Codable, DynamicNodeDecoding {
    
    public let cFEPR: Int
    public let singleTicket: [ITDSingleTicket]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.cFEPR:
                return .attribute
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case cFEPR = "cFEPR"
        case singleTicket = "itdSingleTicket"
    }
    
}
