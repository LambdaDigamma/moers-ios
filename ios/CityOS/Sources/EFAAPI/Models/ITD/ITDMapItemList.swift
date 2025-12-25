//
//  ITDMapItemList.swift
//  
//
//  Created by Lennart Fischer on 26.07.20.
//

import Foundation
import XMLCoder

public struct ITDMapItemList: Codable, DynamicNodeDecoding {
    
    public var items: [ITDMapItem]
    
    public enum CodingKeys: String, CodingKey {
        case items = "itdMapItem"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .element
    }
    
}
