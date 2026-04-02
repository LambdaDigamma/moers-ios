//
//  ITDDateRange.swift
//  
//
//  Created by Lennart Fischer on 19.04.21.
//

import Foundation
import XMLCoder

public struct ITDDateRange: Codable, Equatable, Hashable, Sendable, DynamicNodeDecoding {
    
    public var dates: [ITDDate]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .element
    }
    
    public enum CodingKeys: String, CodingKey {
        case dates = "itdDate"
    }
    
}
