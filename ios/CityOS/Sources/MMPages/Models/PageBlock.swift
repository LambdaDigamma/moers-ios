//
//  PageBlock.swift
//  
//
//  Created by Lennart Fischer on 14.01.21.
//

import Foundation
import MediaLibraryKit

public struct PageBlock: BasePageBlock {
    
    public typealias ID = Int
    
    public let id: ID
    public var pageID: Page.ID?
    public var type: String
    public var data: AnyBlockable
    public var children: [PageBlock] = []
    public var mediaCollectionsContainer: MediaCollectionsContainer?
    public var order: Int
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public var blockType: BlockType
    
    public init(
        id: ID,
        pageID: Page.ID,
        blockType: BlockType,
        data: AnyBlockable,
        children: [PageBlock] = [],
        order: Int = 0,
        mediaCollectionsContainer: MediaCollectionsContainer? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date()
    ) {
        self.id = id
        self.pageID = pageID
        self.type = blockType.rawValue
        self.blockType = blockType
        self.data = data
        self.children = children
        self.order = order
        self.mediaCollectionsContainer = mediaCollectionsContainer
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(ID.self, forKey: .id)
        self.pageID = try container.decode(Page.ID?.self, forKey: .pageID)
        self.type = try container.decode(String.self, forKey: .type)
        self.order = try container.decodeIfPresent(Int.self, forKey: .order) ?? 0
        self.createdAt = try container.decode(Date?.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        self.children = try container.decodeIfPresent([PageBlock].self, forKey: .children) ?? []
        
        self.mediaCollectionsContainer = try container.decodeIfPresent(
            MediaCollectionsContainer.self,
            forKey: .mediaCollectionsContainer
        )
        
        if let type = try? container.decode(BlockType.self, forKey: .type) {
            
            self.blockType = type
            
            let block = try type.metatype.init(from: container.superDecoder(forKey: .data))
            self.data = AnyBlockable(block)
            
        } else {
            self.blockType = .unknown
            self.data = AnyBlockable(UnknownBlock())
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(pageID, forKey: .pageID)
        try container.encode(type, forKey: .type)
        // todo: encode data and so on
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // try container.encode(type(of: data).type, forKey: .type)
        // try data.encode(to: container.superEncoder(forKey: .data))
        
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case pageID = "page_id"
        case type = "type"
        case data = "data"
        case order = "order"
        case children = "children"
        case mediaCollectionsContainer = "media_collections"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public static func stub(withID id: Int) -> PageBlock {
        return PageBlock(
            id: id,
            pageID: 0,
            blockType: .unknown,
            data: AnyBlockable(UnknownBlock())
        )
    }
    
}
