//
//  FavoriteEventsStoreTests.swift
//  
//
//  Created by Lennart Fischer on 29.04.23.
//

import Foundation
import XCTest
@testable import MMEvents

final class FavoriteEventsStoreTests: XCTestCase {
    
    func testEventIsLiked() async throws {
        
        let db = MemoryDatabase.default()
        
        let eventStore = EventStore(writer: db, reader: db)
        let favoriteEventsStore = FavoriteEventsStore(writer: db, reader: db)
        
        let event = Event.stub(withID: 1)
        
        try await eventStore.insert(event)
        try await favoriteEventsStore.createFavoriteEvent(eventID: event.id)
        
        let isFavorite = try await favoriteEventsStore.isFavorite(eventID: event.id)
        
        XCTAssertTrue(isFavorite)
        
    }
    
    func testDeleteFavoriteEvent() async throws {
        
        let db = MemoryDatabase.default()
        
        let eventStore = EventStore(writer: db, reader: db)
        let favoriteEventsStore = FavoriteEventsStore(writer: db, reader: db)
        
        let event = Event.stub(withID: 1)
        
        try await eventStore.insert(event)
        try await favoriteEventsStore.createFavoriteEvent(eventID: event.id)
        
        let isFavorite = try await favoriteEventsStore.isFavorite(eventID: event.id)
        
        XCTAssertTrue(isFavorite)
        
    }
    
    func testToggleFavoriteEvent() async throws {
        
        let db = MemoryDatabase.default()
        
        let eventStore = EventStore(writer: db, reader: db)
        let favoriteEventsStore = FavoriteEventsStore(writer: db, reader: db)
        
        let event = Event.stub(withID: 1)
        
        try await eventStore.insert(event)
        
        try await favoriteEventsStore.toggleFavoriteEvent(eventID: event.id)
        
        var isFavorite = try await favoriteEventsStore.isFavorite(eventID: event.id)
        
        XCTAssertTrue(isFavorite)
        
        try await favoriteEventsStore.toggleFavoriteEvent(eventID: event.id)
        
        isFavorite = try await favoriteEventsStore.isFavorite(eventID: event.id)
        
        XCTAssertFalse(isFavorite)
        
    }
    
}
