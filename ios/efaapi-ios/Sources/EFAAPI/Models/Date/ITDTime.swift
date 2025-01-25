//
//  ITDTime.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public struct ITDTime: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public var hour: Int
    public var minute: Int
    
    public enum CodingKeys: String, CodingKey {
        case hour
        case minute
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
    public var formatted: String {
        return "\(hour):\(minute)"
    }
    
}
