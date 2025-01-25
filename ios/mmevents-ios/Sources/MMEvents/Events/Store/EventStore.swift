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
