//
//  PlaceStore.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import GRDB
import Factory
import Combine

public final class PlaceStore {
    
    private let writer: DatabaseWriter
    private let reader: DatabaseReader
    
    public init(
        writer: DatabaseWriter,
        reader: DatabaseReader
    ) {
        self.writer = writer
        self.reader = reader
    }
    
    public func fetch() async throws -> [PlaceRecord] {
        
        try await reader.read { db in
            return try PlaceRecord.fetchAll(db)
        }
        
    }
    
    public func fetch() -> AnyPublisher<[PlaceRecord], Error> {
        
        reader.readPublisher { db in
            return try PlaceRecord.fetchAll(db)
        }.eraseToAnyPublisher()
        
    }
    
    public func fetch(search: String) async throws -> [PlaceRecord] {
        
        try await reader.read({ db in
            
            return try PlaceRecord
                .filter(PlaceRecord.Columns.name.like("%\(search)%"))
                .fetchAll(db)
            
        })
        
    }
    
    public func show(placeID: Place.ID) async throws -> PlaceRecord {
        
        try await reader.read({ db in
            
            return try PlaceRecord.find(db, key: placeID)
            
        })
        
    }
    
    @discardableResult
    public func insert(_ place: PlaceRecord) async throws -> PlaceRecord {
        
        try await writer.write { db in
            return try place.inserted(db)
        }
        
    }
    
    public func updateOrCreate(_ places: [PlaceRecord]) async throws -> [PlaceRecord] {
        
        try await writer.write({ db in
            
            var updatedPlaces: [PlaceRecord] = []
            
            for place in places {
                updatedPlaces.append(try place.inserted(db, onConflict: .replace))
            }
            
            return updatedPlaces
            
        })
        
    }
    
    public func delete(_ place: PlaceRecord) async throws -> Bool {
        
        try await writer.write { db in
            return try place.delete(db)
        }
        
    }
    
    public func changeObserver() -> AnyPublisher<[PlaceRecord], Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try PlaceRecord.fetchAll(db)
            }
            .removeDuplicates()
        
        return observation.publisher(in: reader).eraseToAnyPublisher()
        
    }
    
}
