//
//  ITDDate.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public struct ITDDate: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public var weekday: Int
    public var year: Int
    public var month: Int
    public var day: Int
    
    public enum CodingKeys: String, CodingKey {
        case weekday
        case year
        case month
        case day
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            default:
                return .attribute
        }
    }
    
}
