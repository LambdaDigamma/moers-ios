//
//  EventStoreTests.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation
import XCTest
@testable import MMEvents

final class EventStoreTests: XCTestCase {
    
    func testEvent() async throws {
        
        let (store, writer) = EventStore.inMemory()
        
        let placeStore = PlaceStore(writer: writer, reader: writer)
        
        let place = Place.stub(withID: 1)
        
        let event = Event(id: 1, name: "Test Event", placeID: 1)
        
        try await placeStore.insert(place.toRecord())
        try await store.insert(event)
        
        try await writer.read { db in
            
            let request = EventRecord.including(optional: EventRecord.place)
            let events = try EventWithPlace.fetchAll(db, request)
            
            print(events.first)
            
        }
        
        
        
//        let events = try await store.fetch()
        
//        print(events.first?.place)
        
    }
    
}
