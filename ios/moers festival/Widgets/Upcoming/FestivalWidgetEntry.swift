//
//  FestivalWidgetEntry.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//

import WidgetKit
import SwiftUI

struct FestivalWidgetEntry: TimelineEntry {

    let date: Date
    let kind: WidgetKind
    let subtitle: String
    let liveEvents: [FestivalWidgetDisplayEvent]
    let upcomingEvents: [FestivalWidgetDisplayEvent]
    let emptyMessage: String
    let nextRefreshDate: Date

    var allEvents: [FestivalWidgetDisplayEvent] {
        liveEvents + upcomingEvents
    }

    var primaryURL: URL {
        allEvents.first.map { WidgetConstants.eventURL(for: $0.event.id) } ?? kind.fallbackURL
    }

}

extension FestivalWidgetEntry {

    static var previewUpcoming: Self {
        FestivalWidgetEntry(
            date: .now,
            kind: .upcoming,
            subtitle: "All venues",
            liveEvents: [
                FestivalWidgetDisplayEvent(
                    event: FestivalWidgetEvent(
                        id: 1,
                        name: "Exploding Star Trio",
                        startDate: .now.addingTimeInterval(-5 * 60),
                        endDate: .now.addingTimeInterval(25 * 60),
                        placeID: 11,
                        place: FestivalWidgetVenue(id: 11, name: "Festivalhalle", streetName: nil, streetNumber: nil),
                        extras: nil
                    ),
                    status: .live
                )
            ],
            upcomingEvents: [
                FestivalWidgetDisplayEvent(
                    event: FestivalWidgetEvent(
                        id: 2,
                        name: "Late Session",
                        startDate: .now.addingTimeInterval(50 * 60),
                        endDate: .now.addingTimeInterval(110 * 60),
                        placeID: 12,
                        place: FestivalWidgetVenue(id: 12, name: "AmViehTheater", streetName: nil, streetNumber: nil),
                        extras: nil
                    ),
                    status: .upcoming
                ),
                FestivalWidgetDisplayEvent(
                    event: FestivalWidgetEvent(
                        id: 4,
                        name: "Morning Ritual",
                        startDate: .now.addingTimeInterval(90 * 60),
                        endDate: .now.addingTimeInterval(150 * 60),
                        placeID: 13,
                        place: FestivalWidgetVenue(id: 13, name: "Schlosspark", streetName: nil, streetNumber: nil),
                        extras: nil
                    ),
                    status: .upcoming
                )
            ],
            emptyMessage: "No upcoming events.",
            nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.minimumRefreshInterval)
        )
    }

    static var previewFavorites: Self {
        FestivalWidgetEntry(
            date: .now,
            kind: .favorites,
            subtitle: "2 saved",
            liveEvents: [],
            upcomingEvents: [
                FestivalWidgetDisplayEvent(
                    event: FestivalWidgetEvent(
                        id: 3,
                        name: "Solo Set",
                        startDate: .now.addingTimeInterval(20 * 60),
                        endDate: .now.addingTimeInterval(60 * 60),
                        placeID: 13,
                        place: FestivalWidgetVenue(id: 13, name: "Schlosspark", streetName: nil, streetNumber: nil),
                        extras: nil
                    ),
                    status: .upcoming
                ),
                FestivalWidgetDisplayEvent(
                    event: FestivalWidgetEvent(
                        id: 5,
                        name: "Night Procession",
                        startDate: .now.addingTimeInterval(95 * 60),
                        endDate: .now.addingTimeInterval(140 * 60),
                        placeID: 14,
                        place: FestivalWidgetVenue(id: 14, name: "Rodelberg", streetName: nil, streetNumber: nil),
                        extras: nil
                    ),
                    status: .upcoming
                )
            ],
            emptyMessage: "No upcoming favorite events yet.",
            nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.minimumRefreshInterval)
        )
    }

}
