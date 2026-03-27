//
//  PlaceRepository.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import Combine
import GRDB
import Factory

extension Container {
    
    public var placeRepository: Factory<PlaceRepository> {
        Factory(self) {
            
            guard let dbQueue = try? DatabaseQueue(path: ":memory:") else { fatalError() }
            
            return PlaceRepository(
                store: PlaceStore(writer: dbQueue, reader: dbQueue),
                service: StaticPlaceService(places: .success([]))
            )
            
        }.singleton
    }
    
}

public class PlaceRepository: @unchecked Sendable {

    public let store: PlaceStore
    public let service: PlaceService

    public init(store: PlaceStore, service: PlaceService) {
        self.store = store
        self.service = service
    }
    
    public func fetch() async throws -> [Place] {
        return try await store
            .fetch()
            .map { $0.toBase() }
    }
    
    public func fetch(search: String) async throws -> [Place] {
        return try await store
            .fetch(search: search)
            .map { $0.toBase() }
    }
    
    public func showPlace(_ placeID: Place.ID) async throws -> Place? {
        
//        do {
//            return try await store.show(placeID: placeID)
//        } catch RecordError.recordNotFound {
//
//        }
        
//        let place = try await store.
        return nil
    }
    
    public func refresh() {
        
        Task(priority: .background) {
            
            let places: [Place] = try await service.getPlaces().data
            
            let _ = try await self.store
                .updateOrCreate(places.map({ $0.toRecord() }))
            
        }
        
    }
    
    public func data() async throws -> [Place] {

        let cachedPlaces = (try? await fetch()) ?? []

        do {
            let places = try await service.getPlaces().data
            _ = try await store.updateOrCreate(places.map({ $0.toRecord() }))
            return places
        } catch {
            if !cachedPlaces.isEmpty {
                return cachedPlaces
            }
            throw error
        }

    }
    
    public func changeObserver() -> AnyPublisher<[Place], Error> {
        
        return store.changeObserver().map { (records: [PlaceRecord]) in
            return records.map { (record: PlaceRecord) in
                return record.toBase()
            }
        }
        .eraseToAnyPublisher()
        
    }
    
}
