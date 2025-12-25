//
//  BlockImageCollection.swift
//  
//
//  Created by Lennart Fischer on 25.05.22.
//

import Foundation
import ProseMirror

public struct BlockImageCollection: Blockable {
    
    public static var type: BlockType = .imageCollection
    
    public var text: Document?
    
    public enum CodingKeys: String, CodingKey {
        case text = "text"
    }
    
}

