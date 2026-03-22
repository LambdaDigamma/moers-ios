//
//  ExternalLink.swift
//  
//
//  Created by Lennart Fischer on 04.03.20.
//

import Foundation

final public class ExternalLinkBlock: NSObject, Blockable {
    
    public static let type: BlockType = .externalLink
    
    public var url: String
    
}
