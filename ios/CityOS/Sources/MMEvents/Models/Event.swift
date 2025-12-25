//
//  Event.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import MMPages
import MediaLibraryKit

public struct Event: BaseEvent {
    
    public typealias ID = Int
    
    public var id: ID
    public var name: String
    public var description: String? = nil
    public var url: String? = nil
    public var startDate: Date? = nil
    public var endDate: Date? = nil
    public var category: String? = nil
    public var imagePath: String? = nil
    public var web: URL? = nil
    public var image: URL? = nil
    public var extras: EventExtras? = nil
    public var pageID: Page.ID? = nil
    public var placeID: Place.ID? = nil
    public var artists: [String?]? = nil
    public var createdAt: Date? = Date()
    public var updatedAt: Date? = Date()
    public var publishedAt: Date?
    
    public var mediaCollections: MediaCollectionsContainer
    
    public init(
        id: ID,
        name: String,
        description: String? = nil,
        url: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        category: String? = nil,
        imagePath: String? = nil,
        web: URL? = nil,
        image: URL? = nil,
        extras: EventExtras? = nil,
        artists: [String]? = nil,
        pageID: Page.ID? = nil,
        placeID: Place.ID? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date(),
        publishedAt: Date? = nil,
        mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.url = url
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.imagePath = imagePath
        self.web = web
        self.image = image
        self.extras = extras
        self.artists = artists
        self.pageID = pageID
        self.placeID = placeID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
        self.mediaCollections = mediaCollections
    }
    
    // Relations
    public var page: Page? = nil
    public var place: Place? = nil
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case description = "description"
        case url = "url"
        case startDate = "start_date"
        case endDate = "end_date"
        case category = "category"
        case imagePath = "image_path"
        case web = "web"
        case image = "image"
        case extras = "extras"
        case pageID = "page_id"
        case placeID = "place_id"
        case artists = "artists"
        case page = "page"
        case place = "place"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case mediaCollections = "media_collections"
    }
    
    public var isOpenEnd: Bool {
        
        if let openEnd = extras?.openEnd {
            return openEnd
        }
        
        return false
        
    }
    
    public var isPreview: Bool {
        return extras?.isPreview ?? false
    }
    
}

extension Event {
    
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        return decoder
    }
    
    public static func stub(withID id: Event.ID) -> Event {
        
        return Event(
            id: id,
            name: "Test Event",
            description: nil,
            url: nil,
            startDate: nil,
            endDate: nil,
            category: nil,
            imagePath: nil,
            extras: nil,
            createdAt: Date(),
            updatedAt: Date(),
            publishedAt: Date()
        )
        
    }
    
}
