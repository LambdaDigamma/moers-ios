//
//  EventRepository.swift
//  
//
//  Created by Lennart Fischer on 11.03.23.
//

import Foundation
import Combine
import Factory
import GRDB
import MMPages

extension Container {
    
    public var eventRepository: Factory<EventRepository> {
        Factory(self) {

            guard let dbQueue = try? DatabaseQueue(path: ":memory:") else { fatalError() }
            
            return EventRepository(
                store: EventStore(writer: dbQueue, reader: dbQueue),
                service: StaticEventService(events: .success([])),
                pageStore: PageStore(writer: dbQueue, reader: dbQueue)
            )

        }.singleton
    }
    
}

public class EventRepository {
    
    public let store: EventStore
    public let service: EventService
    public let placeStore: PlaceStore?
    public let pageStore: PageStore?
    
    public init(store: EventStore, service: EventService, placeStore: PlaceStore? = nil, pageStore: PageStore?) {
        self.store = store
        self.service = service
        self.placeStore = placeStore
        self.pageStore = pageStore
    }
    
    // MARK: - Data Source
    
    public func events(between startDate: Date, and endDate: Date) -> AnyPublisher<[Event], Error> {
        
        return store.observeEvents(between: startDate, and: endDate)
            .map { $0.map { $0.event.toBase(with: $0.place?.toBase()) } }
            .eraseToAnyPublisher()
        
    }
    
    public func events() -> AnyPublisher<[Event], Error> {
        
        return store.observeAllEvents()
            .map { $0.map { $0.toBase() } }
            .eraseToAnyPublisher()
        
    }
    
    public func eventDetail(id: Event.ID) -> AnyPublisher<Event?, Error> {
        
        return store.observeEvent(id: id)
            .map({ (record: EventWithPlace?) in
                let eventRecord: EventRecord? = record?.event
                let placeRecord: PlaceRecord? = record?.place
                
                return eventRecord?.toBase(with: placeRecord?.toBase())
            })
            .eraseToAnyPublisher()
        
    }
    
    // MARK: - Networking
    
    /// Refreshes the events while skipping all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    public func refreshEvents(withPages: Bool = false) async throws {
        
        let resource = try await service.index(cacheMode: .revalidate, withPages: withPages)
        
        Task(priority: .userInitiated) {
            
            try await updateStore(events: resource.data)
            
        }
            
    }
    
    /// Reloads the events while going through all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    ///
    /// - Throws: An error when an error occurs while loading the
    /// data from the network.
    public func reloadEvents() async throws {
        
        let resource = try await service.index(cacheMode: .cached, withPages: false)
        
        Task(priority: .userInitiated) {
            try await updateStore(events: resource.data)
        }
        
    }
    
    public func refreshEvent(for eventID: Event.ID) async throws {
        
        let resource = try await service.show(event: eventID, cacheMode: .revalidate)
        
        try await updateStore(event: resource.data)
        
    }
    
    public func reloadEvent(for eventID: Event.ID) async throws {
        
        let resource = try await service.show(event: eventID, cacheMode: .cached)
        
        try await updateStore(event: resource.data)
        
    }
    
    // MARK: - Database Handling
    
    /// Write the events to the database.
    ///
    /// - Throws: any errors from the underlying database implementation.
    private func updateStore(events: [Event]) async throws {
        
//        if events.isEmpty {
//            return
//        }
        
        try await store.deleteAllAndInsert(events.map { $0.toRecord() })
        
        if let placeStore {
            
            for event in events {
                
                if let place = event.place?.toRecord() {
                    try await placeStore.insert(place)
                }
                
            }
            
        }
        
        if let pageStore {
            
            let pages = events.compactMap { $0.page }
            let blocks = pages.map { $0.blocks.map { $0.toRecord() } }.reduce([], +)
            
            try await pageStore.updateOrCreate(pages.compactMap { $0.toRecord() })
            try await pageStore.updateOrCreate(blocks)
            
        }
        
    }
    
    private func updateStore(event: Event) async throws {
        
        try await store.updateOrCreate([event.toRecord()])
        
        if let placeStore {
            
            if let place = event.place?.toRecord() {
                try await placeStore.insert(place)
            }
            
        }
        
        if let pageStore, let page = event.page {
            
            try await pageStore.updateOrCreate([page.toRecord()])
            try await pageStore.updateOrCreate(page.blocks.map { $0.toRecord() })
            
        }
        
    }
    
}
