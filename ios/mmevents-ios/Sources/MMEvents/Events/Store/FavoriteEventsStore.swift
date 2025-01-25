//
//  FavoriteEventsStore.swift
//  
//
//  Created by Lennart Fischer on 29.04.23.
//

import Foundation
import GRDB
import Combine
import Factory

extension Container {
    
    public var favoriteEventsStore: Factory<FavoriteEventsStore?> {
        Factory(self) {
            
            return nil
            
        }.singleton
    }
    
}

// Fetch all liked events along with their details
public struct FavoriteEventInfo: Decodable, FetchableRecord, Equatable {
    public var favorite: FavoriteEventRecord
    public var event: EventRecord
    public var place: PlaceRecord?
}

final public class FavoriteEventsStore {
    
    private let writer: DatabaseWriter
    private let reader: DatabaseReader
    
    public init(
        writer: DatabaseWriter,
        reader: DatabaseReader
    ) {
        self.writer = writer
        self.reader = reader
    }
    
    public func isFavorite(eventID: Event.ID) async throws -> Bool {
        
        return try await reader.read { db in
            return try FavoriteEventRecord
                .filter(FavoriteEventRecord.Columns.eventID == eventID)
                .isEmpty(db) == false
        }
        
    }
    
    @discardableResult
    public func createFavoriteEvent(eventID: Event.ID) async throws -> FavoriteEventRecord {
        
        return try await writer.write { db in
            return try FavoriteEventRecord(id: nil, eventID: eventID.toInt64(), createdAt: Date(), updatedAt: Date())
                .inserted(db)
        }
        
    }
    
    public func deleteFavoriteEvent(eventID: Event.ID) async throws {
        
        _ = try await writer.write { db in
            try FavoriteEventRecord
                .filter(FavoriteEventRecord.Columns.eventID == eventID)
                .deleteAll(db)
        }
        
    }
    
    @discardableResult
    public func toggleFavoriteEvent(eventID: Event.ID) async throws -> Bool {
        
        if try await isFavorite(eventID: eventID) {
            try await deleteFavoriteEvent(eventID: eventID)
            return false
        } else {
            try await createFavoriteEvent(eventID: eventID)
            return true
        }
        
    }
    
    public func allLikedEvents() async throws -> [FavoriteEventInfo] {
        
        return try await reader.read { db in
            return try FavoriteEventRecord
                .including(required: FavoriteEventRecord.event)
                .asRequest(of: FavoriteEventInfo.self)
                .fetchAll(db)
        }
        
    }
    
    public func observeFavoriteEvents(
        for collection: String = "festival24"
    ) -> AnyPublisher<[FavoriteEventInfo], Error> {
        
        let currentDate = Date()
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: currentDate))!
        
        return ValueObservation
            .tracking { db in
                
                return try FavoriteEventRecord
                    .including(required: FavoriteEventRecord.event)
                    .including(optional: FavoriteEventRecord.place)
                    .asRequest(of: FavoriteEventInfo.self)
                    .fetchAll(db)
            }
            .removeDuplicates()
            .publisher(in: reader)
            .map {
                $0.sorted {
                    ($0.event.startDate ?? Date.distantFuture) <
                    ($1.event.startDate ?? Date.distantFuture)
                }.filter {
                    if let startDate = $0.event.startDate {
                        return startDate >= startOfYear
                    } else {
                        return true
                    }
                }
            }
            .eraseToAnyPublisher()
        
    }
    
    // MARK: - Observer
    
    public func isLiked(eventID: Event.ID) -> AnyPublisher<Bool, Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try FavoriteEventRecord
                    .filter(FavoriteEventRecord.Columns.eventID == eventID)
                    .fetchOne(db)
            }
            .removeDuplicates()
        
        return observation
            .publisher(in: reader)
            .map({ (record: FavoriteEventRecord?) in
                return record != nil
            })
            .eraseToAnyPublisher()
        
    }
    
}
