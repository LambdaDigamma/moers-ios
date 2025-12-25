//
//  Post.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation
import MediaLibraryKit
import AVFoundation

public typealias VimeoID = String

public struct Post: BasePost, Codable {
    
    public typealias ID = Int
    public typealias FeedID = Feed.ID
    public typealias PageID = Int
    
    public var id: ID
    public var title: String
    public var summary: String
    public var feedID: FeedID?
    public var pageID: PageID?
    public var vimeoID: VimeoID?
    public var publication: Publication?
    public var externalHref: String?
    public var publishedAt: Date? = Date()
    public var createdAt: Date? = Date()
    public var updatedAt: Date? = Date()
    
    public var extras: PostExtras?
    
    public var mediaCollections: MediaCollectionsContainer?
    
    public static func stub(withID id: Int) -> Post {
        return Post(id: id,
                    title: "Test Feed Item",
                    summary: "That is a very short description of the feed item.",
                    feedID: 0,
                    pageID: 0)
    }
    
    public var preferredVideoFile: URL? {
    
        if let hlsVideo = extras?
            .videoFiles?
            .filter({ $0.quality ?? "" == "hls" })
            .first?
            .link {
            
            return hlsVideo
        }
        
        // TODO: Check for a better condition based on size?
        return extras?.videoFiles?.first?.link
    
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case summary = "summary"
        case feedID = "feed_id"
        case pageID = "page_id"
        case vimeoID = "vimeo_id"
        case externalHref = "external_href"
        case publication = "publication"
        case mediaCollections = "media_collections"
        case extras = "extras"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
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
    
    public func mediaAspectRatio() -> CGSize {
        
        if let extras {
            
            switch extras.type {
                case "instagram":
                    return CGSize(width: 1, height: 1)
                default:
                    return CGSize(width: 16, height: 9)
            }
            
        } else {
            return CGSize(width: 16, height: 9)
        }
        
    }
    
//    public static func == (lhs: Post, rhs: Post) -> Bool {
//        return lhs.id == rhs.id
//    }
    
}
