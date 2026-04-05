//
//  VenueEntity.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import AppIntents

struct VenueEntity: AppEntity, Identifiable, Sendable {

    static let defaultQuery = FestivalVenueEntityQuery()
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Venue"

    let id: Int

    @Property(title: "Name")
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(venue: FestivalWidgetVenue) {
        self.id = venue.id
        self.name = venue.name
    }

}
