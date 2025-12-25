//
//  EventRecord.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import GRDB
import MMPages
import MediaLibraryKit

public struct EventRecord: Equatable, Codable {
    
    public var id: Int64?
    public var name: String
    public var description: String? = nil
    public var startDate: Date? = nil
    public var endDate: Date? = nil
    
    public var url: String? = nil
    public var category: String? = nil
    
    public var pageID: Int64? = nil
    public var placeID: Int64? = nil
    
    public var publishedAt: Date? = nil
    public var cancelledAt: Date? = nil
    public var scheduledAt: Date? = nil
    public var createdAt: Date? = Date()
    public var updatedAt: Date? = Date()
    public var archivedAt: Date? = nil
    public var deletedAt: Date? = nil
    
    public var artists: [String]? = nil
    public var mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer()
    
    public var extras: EventExtras?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case startDate = "start_date"
        case endDate = "end_date"
        case url
        case category
        case pageID = "page_id"
        case placeID = "place_id"
        case publishedAt = "published_at"
        case cancelledAt = "cancelled_at"
        case scheduledAt = "scheduled_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case archivedAt = "archived_at"
        case deletedAt = "deleted_at"
        case artists = "artists"
        case mediaCollections = "media_collections"
        case extras = "extras"
    }
    
    public func toBase(with place: Place? = nil) -> Event {
        
        var event = Event(
            id: id.toInt() ?? 0,
            name: name,
            description: description,
            url: url,
            startDate: startDate,
            endDate: endDate,
            category: category,
            imagePath: nil,
            web: url != nil ? URL(string: url ?? "") : nil,
            image: nil,
            extras: self.extras,
            artists: artists,
            pageID: pageID.toInt(),
            placeID: placeID.toInt(),
            createdAt: createdAt,
            updatedAt: updatedAt,
            publishedAt: publishedAt,
            mediaCollections: mediaCollections
        )
        
        event.place = place
        
        return event
        
    }
    
}

extension EventRecord: FetchableRecord, MutablePersistableRecord {
    
    public static var databaseTableName: String = EventTableDefinition.tableName
    
    public enum Columns {
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
        static let startDate = Column(CodingKeys.startDate)
        static let endDate = Column(CodingKeys.startDate)
        static let placeID = Column(CodingKeys.placeID)
        static let archivedAt = Column(CodingKeys.archivedAt)
    }
    
    mutating public func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    static let placeForeignKey = ForeignKey(["place_id"])
    
    static let place = belongsTo(PlaceRecord.self, using: placeForeignKey)
    static let page = belongsTo(PageRecord.self)
    
    var place: QueryInterfaceRequest<PlaceRecord> {
        request(for: EventRecord.place)
    }
    
}

extension Event {
    
    public func toRecord() -> EventRecord {
        
        return EventRecord(
            id: Int64(truncatingIfNeeded: self.id),
            name: self.name,
            description: self.description,
            startDate: self.startDate,
            endDate: self.endDate,
            url: self.url,
            category: self.category,
            pageID: self.pageID.toInt64(),
            placeID: self.placeID.toInt64(),
            publishedAt: self.publishedAt,
            cancelledAt: nil,
            scheduledAt: nil,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            archivedAt: nil,
            deletedAt: nil,
            artists: self.artists?.compactMap { $0 },
            mediaCollections: self.mediaCollections,
            extras: self.extras
        )
        
    }
    
}
