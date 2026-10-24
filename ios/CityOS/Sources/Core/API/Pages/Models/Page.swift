//
//  Page.swift
//  
//
//  Created by Lennart Fischer on 04.02.20.
//

import Foundation

public struct Page: Codable {
    
    public typealias ID = Int
    
    public var title: String
    public let slug: String
    public var blocks: [Blockable]
    public var creatorID: Int?
    public var createdAt: Date?
    public var updatedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case title
        case slug
        case creatorID = "creator_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case blocks
    }
    
    public init(title: String = "", slug: String = "", blocks: [Blockable]) {
        self.title = title
        self.slug = slug
        self.blocks = blocks
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.slug = try container.decode(String.self, forKey: .slug)
        self.blocks = try container.decode([AnyBlockable].self, forKey: .blocks).map { $0.data }
        self.creatorID = try container.decodeIfPresent(Int.self, forKey: .creatorID)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(slug, forKey: .slug)
        try container.encode(blocks.map(AnyBlockable.init), forKey: .blocks)
        try container.encode(creatorID, forKey: .creatorID)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
    }
    
}
