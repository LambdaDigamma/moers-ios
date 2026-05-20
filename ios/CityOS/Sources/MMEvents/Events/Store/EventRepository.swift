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

            let configuration = EventSearchDatabaseFunctions.configuration()
            guard let dbQueue = try? DatabaseQueue(
                path: ":memory:",
                configuration: configuration
            ) else { fatalError() }
            
            return EventRepository(
                store: EventStore(writer: dbQueue, reader: dbQueue),
                service: StaticEventService(events: .success([])),
                pageStore: PageStore(writer: dbQueue, reader: dbQueue)
            )

        }.singleton
    }
    
}

public class EventRepository: @unchecked Sendable {
    
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
        
        return store.observeAllEventsWithPlace()
            .map { $0.map { $0.event.toBase(with: $0.place?.toBase()) } }
            .eraseToAnyPublisher()
        
    }

    public func searchEvents(query: String) async throws -> [Event] {

        try await store
            .searchEvents(query: query)
            .map { $0.event.toBase(with: $0.place?.toBase()) }

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
        
        try await updateStore(events: resource.data)
            
    }
    
    /// Reloads the events while going through all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    ///
    /// - Throws: An error when an error occurs while loading the
    /// data from the network.
    public func reloadEvents() async throws {
        
        let resource = try await service.index(cacheMode: .cached, withPages: false)
        
        try await updateStore(events: resource.data)
        
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

        if let placeStore {

            let places = events.compactMap { $0.place?.toRecord() }

            if !places.isEmpty {
                try await placeStore.updateOrCreate(places)
            }

        }

        try await store.deleteAllAndInsert(events.map { $0.toRecord() })

        if let pageStore {
            
            let pages = events.compactMap { $0.page }
            let blocks = pages.map { $0.blocks.map { $0.toRecord() } }.reduce([], +)
            
            try await pageStore.updateOrCreate(pages.compactMap { $0.toRecord() })
            try await pageStore.updateOrCreate(blocks)
            
        }
        
    }
    
    private func updateStore(event: Event) async throws {

        if let placeStore {
            
            if let place = event.place?.toRecord() {
                try await placeStore.updateOrCreate([place])
            }
            
        }

        try await store.updateOrCreate([event.toRecord()])
        
        if let pageStore, let page = event.page {
            
            try await pageStore.updateOrCreate([page.toRecord()])
            try await pageStore.updateOrCreate(page.blocks.map { $0.toRecord() })
            
        }
        
    }
    
}
