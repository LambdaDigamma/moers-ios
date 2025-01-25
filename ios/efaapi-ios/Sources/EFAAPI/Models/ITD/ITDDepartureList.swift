//
//  ITDDepartureList.swift
//  
//
//  Created by Lennart Fischer on 19.04.21.
//

import Foundation
import XMLCoder

public struct ITDDepartureList: Codable, DynamicNodeDecoding {
    
    public let departures: [ITDDeparture]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .element
    }
    
    public enum CodingKeys: String, CodingKey {
        case departures = "itdDeparture"
    }
    
}
