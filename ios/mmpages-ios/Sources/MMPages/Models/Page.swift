//
//  Page.swift
//  
//
//  Created by Lennart Fischer on 14.01.21.
//

import Foundation
import MediaLibraryKit

public struct Page: BasePage {
    
    public typealias ID = Int
    public typealias UserID = Int
//    public typealias Block = PageBlock
    
    public let id: ID
    public var title: String?
    public var summary: String?
    public var pageTemplateID: Int?
    public var slug: String?
    public var blocks: [PageBlock] = []
    public var resourceUrl: String?
    public var creatorID: UserID?
    public var extras: [String : String]?
    public var mediaCollections: MediaCollectionsContainer
    public var archivedAt: Date?
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case summary = "summary"
        case pageTemplateID = "page_template_id"
        case slug = "slug"
        case blocks = "blocks"
        case resourceUrl = "resource_url"
        case creatorID = "creator_id"
        case extras = "extras"
        case mediaCollections = "media_collections"
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: ID,
        title: String?,
        slug: String?,
        summary: String?,
        pageTemplateID: Int? = nil,
        blocks: [PageBlock] = [],
        creatorID: UserID?,
        extras: [String : String]?,
        mediaCollections: MediaCollectionsContainer = .init(),
        archivedAt: Date?,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date()
    ) {
        self.id = id
        self.title = title
        self.slug = slug
        self.summary = summary
        self.pageTemplateID = pageTemplateID
        self.blocks = blocks
        self.creatorID = creatorID
        self.extras = extras
        self.mediaCollections = mediaCollections
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        self.id = try container.decode(ID.self, forKey: .id)
        self.title = try container.decode(String?.self, forKey: .title)
        self.slug = try container.decode(String?.self, forKey: .slug)
        self.summary = try container.decode(String?.self, forKey: .summary)
        self.pageTemplateID = try container.decode(Int?.self, forKey: .pageTemplateID)
        self.blocks = (try container.decodeIfPresent([PageBlock].self, forKey: .blocks) ?? [])
            .sorted(by: { $0.order < $1.order })
        self.creatorID = try container.decodeIfPresent(UserID.self, forKey: .creatorID)
        self.resourceUrl = try container.decodeIfPresent(String.self, forKey: .resourceUrl)
        self.extras = try container.decode([String: String]?.self, forKey: .extras)
        self.mediaCollections = try container.decode(MediaCollectionsContainer.self, forKey: .mediaCollections)
        self.archivedAt = try container.decode(Date?.self, forKey: .archivedAt)
        self.createdAt = try container.decode(Date?.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
    }
    
    public static func stub(withID id: Page.ID) -> Page {
        return Page(
            id: id,
            title: "",
            slug: nil,
            summary: nil,
            blocks: [],
            creatorID: nil,
            extras: nil,
            archivedAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        return decoder
    }
    
}
