//
//  ITDRBLControlled.swift
//  
//
//  Created by Lennart Fischer on 08.04.22.
//

import Foundation
import XMLCoder

public struct ITDRBLControlled: Codable, Hashable, Equatable, DynamicNodeDecoding {
    
    public let delayMinutes: Int
    public let delayMinutesArr: Int
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
    public enum CodingKeys: String, CodingKey {
        case delayMinutes = "delayMinutes"
        case delayMinutesArr = "delayMinutesArr"
    }
    
}
