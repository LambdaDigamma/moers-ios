//
//  BlockImageCollection.swift
//  
//
//  Created by Lennart Fischer on 25.05.22.
//

import Foundation
import ProseMirror

public struct BlockImageCollection: Blockable, Equatable {

    public static let type: BlockType = .imageCollection

    public var text: Document?

    public enum CodingKeys: String, CodingKey {
        case text = "text"
    }

    public static func == (lhs: BlockImageCollection, rhs: BlockImageCollection) -> Bool {
        return true
    }

}

