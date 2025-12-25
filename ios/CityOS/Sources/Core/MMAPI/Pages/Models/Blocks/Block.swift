//
//  Block.swift
//  
//
//  Created by Lennart Fischer on 05.02.20.
//

import Foundation

public enum BlockType: String, CaseIterable, Codable, CaseIterableDefaultsLast {
    
    case markdown = "markdown"
    case soundcloud = "soundcloud"
    case externalLink = "externalLink"
    
    case unknown = "unknown"
    
    public var metatype: Blockable.Type {
        switch self {
        case .markdown: return MarkdownBlock.self
        case .soundcloud: return SoundCloudBlock.self
        case .externalLink: return ExternalLinkBlock.self
        default: return UnknownBlock.self
        }
    }
    
}

public protocol Blockable: Codable {
    
    static var type: BlockType { get }
    
}

public class AnyBlockable: Codable {
    
    public var data: Blockable
    
    public init(_ base: Blockable) {
        self.data = base
    }
    
    private enum CodingKeys: CodingKey {
        case type, data
    }
    
    required public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(BlockType.self, forKey: .type)
        self.data = try type.metatype.init(from: container.superDecoder(forKey: .data))
        
    }

    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type(of: data).type, forKey: .type)
        try data.encode(to: container.superEncoder(forKey: .data))
        
    }
    
}


protocol CaseIterableDefaultsLast: Decodable & CaseIterable & RawRepresentable
    where Self.RawValue: Decodable, Self.AllCases: BidirectionalCollection { }

extension CaseIterableDefaultsLast {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
