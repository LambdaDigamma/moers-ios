//
//  PostRecord.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import GRDB
import MediaLibraryKit

struct PostRecord: Equatable, Codable {
    
    public var id: Int64?
    public var title: String
    public var summary: String
    public var feedID: Int64?
    public var pageID: Int64?
    public var vimeoID: VimeoID?
    public var publication: Publication?
    public var externalHref: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var publishedAt: Date?
    
    public var extras: PostExtras?
    
    public var mediaCollections: MediaCollectionsContainer?
    
    public var deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case summary = "summary"
        case feedID = "feed_id"
        case pageID = "page_id"
        case vimeoID = "vimeo_id"
        case publication = "publication"
        case externalHref = "external_href"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case extras = "extras"
        case mediaCollections = "media_collections"
        case deletedAt = "deleted_at"
    }
    
}

extension PostRecord: FetchableRecord, MutablePersistableRecord {

    public static var databaseTableName: String = "posts"

    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy = .useDefaultKeys
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy = .useDefaultKeys
    
    internal enum Columns {
        static let publishedAt = Column("published_at")
    }

}

extension MediaCollectionsContainer: @retroactive StatementBinding {}
extension MediaCollectionsContainer: @retroactive SQLExpressible {}
extension MediaCollectionsContainer: @retroactive DatabaseValueConvertible {
    
    public var databaseValue: DatabaseValue {
        let jsonEncoder = JSONEncoder()
        let data = try! jsonEncoder.encode(self)
        let string = String(data: data, encoding: .utf8)
        return string.databaseValue
    }
    
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Self? {
        guard let string = String.fromDatabaseValue(dbValue) else { return nil }
        guard let data = string.data(using: .utf8) else { return nil }
        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(MediaCollectionsContainer.self, from: data)
    }
    
}

extension PostRecord {

    public func toBase() -> Post {

        return Post(
            id: self.id.toInt() ?? -1,
            title: self.title,
            summary: self.summary,
            feedID: self.feedID.toInt(),
            pageID: self.pageID.toInt(),
            vimeoID: self.vimeoID,
            publication: self.publication,
            externalHref: self.externalHref,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            extras: self.extras,
            mediaCollections: self.mediaCollections
        )

    }

}

extension Post {

    func toRecord() -> PostRecord {

        return PostRecord(
            id: self.id.toInt64(),
            title: self.title,
            summary: self.summary,
            feedID: self.feedID?.toInt64(),
            pageID: self.pageID?.toInt64(),
            vimeoID: self.vimeoID,
            publication: self.publication,
            externalHref: self.externalHref,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            publishedAt: self.publishedAt,
            extras: self.extras,
            mediaCollections: self.mediaCollections,
            deletedAt: nil
        )

    }

}
