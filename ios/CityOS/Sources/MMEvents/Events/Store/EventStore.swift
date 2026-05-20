//
//  EventStore.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import GRDB
import Combine

final public class EventStore {

    private let writer: DatabaseWriter
    private let reader: DatabaseReader
    
    public init(
        writer: DatabaseWriter,
        reader: DatabaseReader
    ) {
        self.writer = writer
        self.reader = reader
    }

//    public func fetch() async throws -> [Event] {
//
//        try await reader.read { db in
//            return try EventRecord
//                .joining(required: EventRecord.place)
//                .fetchAll(db)
//                .compactMap { $0.toBase() }
//        }
//
//    }
    
    public func fetch() async throws -> [EventRecord] {
        
        try await reader.read { db in
            return try EventRecord
                .joining(required: EventRecord.place)
                .fetchAll(db)
        }
        
    }

    public func searchEvents(query: String) async throws -> [EventWithPlace] {

        guard Self.hasSearchableQuery(query) else {
            return []
        }

        return try await reader.read { db in
            try Self.fetchSearchEvents(
                matching: query,
                in: db
            )
        }

    }
    
    @discardableResult
    public func insert(_ event: Event) async throws -> Event {

        try await writer.write { db in
            return try event.toRecord().inserted(db).toBase()
        }

    }

    public func delete(_ event: Event) async throws -> Bool {

        try await writer.write { db in
            return try event.toRecord().delete(db)
        }

    }

    @discardableResult
    func updateOrCreate(_ events: [EventRecord]) async throws -> [EventRecord] {
        
        try await writer.write({ db in
            var updatedEvents: [EventRecord] = []
            
            for event in events {
                updatedEvents.append(try event.inserted(db, onConflict: .replace))
            }
            
            return updatedEvents
            
        })
        
    }
    
    @discardableResult
    public func deleteAllAndInsert(_ events: [EventRecord]) async throws -> [EventRecord] {
        
        try await writer.write({ db in
            try EventRecord.deleteAll(db)
            
            var updatedEvents: [EventRecord] = []
            
            for event in events {
                updatedEvents.append(try event.inserted(db, onConflict: .replace))
            }
            
            return updatedEvents
            
        })
        
    }
    
    // MARK: - Observer
    
    public func observeEvents(between startDate: Date, and endDate: Date) -> AnyPublisher<[EventWithPlace], Error> {
        
        let request = EventRecord
            .including(optional: EventRecord.place)
            .order(EventRecord.Columns.startDate.ascNullsLast)
            .filter(EventRecord.Columns.startDate >= startDate && EventRecord.Columns.startDate <= endDate)
        
        let observation = ValueObservation
            .tracking { db in
                try EventWithPlace
                    .fetchAll(db, request)
//                try EventRecord
//                    .order(EventRecord.Columns.startDate.ascNullsLast)
//                    .filter(EventRecord.Columns.startDate >= startDate && EventRecord.Columns.startDate <= endDate)
////                    .filter(EventRecord.Columns.archivedAt == nil)
////                    .joining(required: EventRecord.place)
//                    .fetchAll(db)
            }
            .removeDuplicates()
        
        return observation
//            .publisher(in: reader, scheduling: .immediate)
            .publisher(in: reader)
            .eraseToAnyPublisher()
        
    }
    
    public func observeAllEvents() -> AnyPublisher<[EventRecord], Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try EventRecord
                    .order(EventRecord.Columns.startDate.asc)
//                    .filter(EventRecord.Columns.archivedAt == nil)
//                    .joining(required: EventRecord.place)
                    .fetchAll(db)
            }
            .removeDuplicates()
        
        return observation
            .publisher(in: reader, scheduling: .immediate)
            .eraseToAnyPublisher()
        
    }

    public func observeAllEventsWithPlace() -> AnyPublisher<[EventWithPlace], Error> {
        
        let request = EventRecord
            .including(optional: EventRecord.place)
            .order(EventRecord.Columns.startDate.asc)
        
        let observation = ValueObservation
            .tracking { db in
                try EventWithPlace.fetchAll(db, request)
            }
            .removeDuplicates()
        
        return observation
            .publisher(in: reader, scheduling: .immediate)
            .eraseToAnyPublisher()
        
    }
    
    public func observeEvent(id: Event.ID) -> AnyPublisher<EventWithPlace?, Error> {
        
        let request = EventRecord
            .including(optional: EventRecord.place)
            .filter(key: id)
        
        let observation = ValueObservation
            .trackingConstantRegion({ db in
                try EventWithPlace
                    .fetchOne(db, request)
            })
            .removeDuplicates()
        
        return observation
            .publisher(in: reader, scheduling: .immediate)
            .eraseToAnyPublisher()
        
    }
    
    public func observeEvents(for placeID: Place.ID) -> AnyPublisher<[EventRecord], Error> {
        
        let request = EventRecord
            .order(EventRecord.Columns.startDate.ascNullsLast)
            .filter(EventRecord.Columns.placeID == placeID)
        
        let observation = ValueObservation
            .tracking { db in
                try EventRecord
                    .fetchAll(db, request)
            }
            .removeDuplicates()
        
        return observation
            .publisher(in: reader)
            .eraseToAnyPublisher()
        
    }
    
}

private extension EventStore {

    static func hasSearchableQuery(_ query: String) -> Bool {

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            return false
        }

        return !EventSearchTextNormalizer().normalize(trimmedQuery).isEmpty

    }

    static func fetchSearchEvents(
        matching query: String,
        in db: Database
    ) throws -> [EventWithPlace] {

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            return []
        }

        let normalizedQuery = EventSearchTextNormalizer().normalize(trimmedQuery)

        guard !normalizedQuery.isEmpty else {
            return []
        }

        let escapedQuery = escapedLikePattern(for: normalizedQuery)
        let exactPattern = escapedQuery
        let prefixPattern = "\(escapedQuery)%"
        let containsPattern = "%\(escapedQuery)%"
        let eventIDs = try Int64.fetchAll(
            db,
            sql: """
            SELECT e.id
            FROM events e
            JOIN event_search_view s ON s.event_id = e.id
            WHERE s.normalized_name LIKE ? ESCAPE char(92)
                OR s.normalized_artists LIKE ? ESCAPE char(92)
                OR s.normalized_place_name LIKE ? ESCAPE char(92)
            ORDER BY
                CASE
                    WHEN s.normalized_name LIKE ? ESCAPE char(92) THEN 0
                    WHEN s.normalized_name LIKE ? ESCAPE char(92) THEN 1
                    WHEN s.normalized_name LIKE ? ESCAPE char(92) THEN 2
                    WHEN s.normalized_artists LIKE ? ESCAPE char(92) THEN 3
                    WHEN s.normalized_artists LIKE ? ESCAPE char(92) THEN 4
                    WHEN s.normalized_artists LIKE ? ESCAPE char(92) THEN 5
                    WHEN s.normalized_place_name LIKE ? ESCAPE char(92) THEN 6
                    WHEN s.normalized_place_name LIKE ? ESCAPE char(92) THEN 7
                    WHEN s.normalized_place_name LIKE ? ESCAPE char(92) THEN 8
                    ELSE 9
                END ASC,
                e.start_date IS NULL ASC,
                e.start_date ASC,
                e.name COLLATE NOCASE ASC
            """,
            arguments: [
                containsPattern,
                containsPattern,
                containsPattern,
                exactPattern,
                prefixPattern,
                containsPattern,
                exactPattern,
                prefixPattern,
                containsPattern,
                exactPattern,
                prefixPattern,
                containsPattern
            ]
        )

        return try eventIDs.compactMap { eventID in
            let request = EventRecord
                .including(optional: EventRecord.place)
                .filter(key: eventID)

            return try EventWithPlace.fetchOne(db, request)
        }

    }

    static func escapedLikePattern(for query: String) -> String {

        query.reduce(into: "") { result, character in
            switch character {
            case "%", "_", "\\":
                result.append("\\")
            default:
                break
            }

            result.append(character)
        }

    }

}
