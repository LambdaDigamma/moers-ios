//
//  AnyBlockable.swift
//  
//
//  Created by Lennart Fischer on 23.05.22.
//

import Foundation

public enum BlockType: String, CaseIterable, Codable, CaseIterableDefaultsLast {
    
    case youtubeVideo = "youtube-video"
    case markdown = "markdown"
    case soundcloud = "soundcloud"
    case externalLink = "externalLink"
    case text = "tip-tap-text-with-media"
    case linkList = "link-list"
    case imageCollection = "image-collection"
    
    case unknown = "unknown"
    
    public var metatype: any Blockable.Type {
        switch self {
            case .text: return TextBlock.self
            case .imageCollection: return BlockImageCollection.self
            case .youtubeVideo: return BlockYouTubeVideo.self
            case .linkList: return BlockLinkList.self
            default: return UnknownBlock.self
        }
    }
    
}

public protocol Blockable: Codable {
    
    static var type: BlockType { get }
    
}

public class AnyBlockable: Codable {
    
    public var base: any Blockable
    
    public init(_ base: any Blockable) {
        self.base = base
    }
    
    private enum CodingKeys: CodingKey {
        case type, base
    }
    
    required public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(BlockType.self, forKey: .type)
        self.base = try type.metatype.init(from: container.superDecoder(forKey: .base))
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type(of: base).type, forKey: .type)
        try base.encode(to: container.superEncoder(forKey: .base))
        
    }
    
}


protocol CaseIterableDefaultsLast: Decodable & CaseIterable & RawRepresentable
where Self.RawValue: Decodable, Self.AllCases: BidirectionalCollection { }

extension CaseIterableDefaultsLast {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
