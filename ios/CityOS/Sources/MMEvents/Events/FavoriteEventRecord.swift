//
//  FavoriteEventRecord.swift
//  
//
//  Created by Lennart Fischer on 29.04.23.
//

import Foundation
import GRDB

public struct FavoriteEventRecord: Equatable, Codable {
    
    public var id: Int64?
    public var eventID: Int64
    
    public var createdAt: Date?
    public var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventID = "event_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
}

extension FavoriteEventRecord: FetchableRecord, MutablePersistableRecord {
    
    public static var databaseTableName: String = FavoriteEventsTableDefinition.tableName
    
    public enum Columns {
        static let eventID = Column(CodingKeys.eventID)
    }
    
    mutating public func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    static let eventForeignKey = ForeignKey(["event_id"])
    static let placeForeignKey = ForeignKey(["place_id"])
    
    public static let event = belongsTo(EventRecord.self, using: eventForeignKey)
    public static let place = hasOne(PlaceRecord.self, through: FavoriteEventRecord.event, using: EventRecord.place)
    
    public var event: QueryInterfaceRequest<EventRecord> {
        request(for: FavoriteEventRecord.event)
    }
    
}

public extension Optional where Wrapped == Date {
    
    /// Returns the date components (day, month, year) for the specified date.
    /// If the given date not exceeds the start of the date by the given interval, 
    /// the previous day should be used.
    /// Example: 2024-04-12 02:00:00 with acceptedOffset of `3 * 60 * 60`
    /// returns 2024-03-11 as date components.
    func getDateForGroup(acceptedOffset: Int) -> DateComponents? {
        
        guard var date = self else { return nil }
        
        let calendar = Calendar.autoupdatingCurrent
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let offsetDate = calendar.date(byAdding: .second, value: acceptedOffset, to: startOfDay) else { return nil }
        
        if (startOfDay...offsetDate).contains(date) {
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        
        return calendar.dateComponents([.day, .month, .year], from: date)
        
    }
    
}
