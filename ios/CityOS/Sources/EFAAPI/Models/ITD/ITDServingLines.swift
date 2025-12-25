//
//  ITDServingLines.swift
//  
//
//  Created by Lennart Fischer on 19.04.21.
//

import Foundation
import XMLCoder

public struct ITDServingLines: Codable, DynamicNodeDecoding {
    
    public var lines: [ITDServingLine]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .elementOrAttribute
    }
    
    public enum CodingKeys: String, CodingKey {
        case lines = "itdServingLine"
    }
    
}
