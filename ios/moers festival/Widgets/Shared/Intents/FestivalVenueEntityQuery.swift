//
//  FestivalVenueEntityQuery.swift
//  
//
//  Created by Lennart Fischer on 05.04.26.
//


import AppIntents

@available(iOSApplicationExtension 17.0, *)
struct FestivalVenueEntityQuery: EnumerableEntityQuery, Sendable {

    func allEntities() async throws -> [VenueEntity] {
        try await FestivalWidgetDataStore.loadVenues().map(VenueEntity.init(venue:))
    }

    func entities(for identifiers: [Int]) async throws -> [VenueEntity] {
        let venues = try await allEntities()
        let identifiers = Set(identifiers)
        return venues.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [VenueEntity] {
        try await allEntities()
    }

}
