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
    let subtitleSystemImage: String?
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

    private static func previewVenue(id: Int, name: String) -> FestivalWidgetVenue {
        FestivalWidgetVenue(id: id, name: name, streetName: nil, streetNumber: nil)
    }

    private static func previewEvent(
        id: Int,
        name: String,
        startOffset: TimeInterval,
        endOffset: TimeInterval? = nil,
        placeID: Int,
        venueName: String
    ) -> FestivalWidgetEvent {
        FestivalWidgetEvent(
            id: id,
            name: name,
            startDate: .now.addingTimeInterval(startOffset),
            endDate: endOffset.map { .now.addingTimeInterval($0) },
            placeID: placeID,
            place: previewVenue(id: placeID, name: venueName),
            extras: nil
        )
    }

    private static func previewDisplayEvent(
        id: Int,
        name: String,
        startOffset: TimeInterval,
        endOffset: TimeInterval? = nil,
        placeID: Int,
        venueName: String,
        status: FestivalWidgetStatus
    ) -> FestivalWidgetDisplayEvent {
        FestivalWidgetDisplayEvent(
            event: previewEvent(
                id: id,
                name: name,
                startOffset: startOffset,
                endOffset: endOffset,
                placeID: placeID,
                venueName: venueName
            ),
            status: status
        )
    }

    static var previewUpcoming: Self {
        FestivalWidgetEntry(
            date: .now,
            kind: .upcoming,
            subtitle: "All venues",
            subtitleSystemImage: nil,
            liveEvents: [
                previewDisplayEvent(
                    id: 1,
                    name: "Exploding Star Trio",
                    startOffset: -5 * 60,
                    endOffset: 25 * 60,
                    placeID: 11,
                    venueName: "Festivalhalle",
                    status: .live
                )
            ],
            upcomingEvents: [
                previewDisplayEvent(
                    id: 2,
                    name: "Late Session",
                    startOffset: 50 * 60,
                    endOffset: 110 * 60,
                    placeID: 12,
                    venueName: "AmViehTheater",
                    status: .upcoming
                ),
                previewDisplayEvent(
                    id: 4,
                    name: "Morning Ritual",
                    startOffset: 90 * 60,
                    endOffset: 150 * 60,
                    placeID: 13,
                    venueName: "Schlosspark",
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
            subtitle: "",
            subtitleSystemImage: nil,
            liveEvents: [],
            upcomingEvents: [
                previewDisplayEvent(
                    id: 3,
                    name: "Solo Set",
                    startOffset: 20 * 60,
                    endOffset: 60 * 60,
                    placeID: 13,
                    venueName: "Schlosspark",
                    status: .upcoming
                ),
                previewDisplayEvent(
                    id: 5,
                    name: "Night Procession",
                    startOffset: 95 * 60,
                    endOffset: 140 * 60,
                    placeID: 14,
                    venueName: "Rodelberg",
                    status: .upcoming
                )
            ],
            emptyMessage: "No upcoming favorite events yet.",
            nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.minimumRefreshInterval)
        )
    }

    static var previewUpcomingFilteredChaos: Self {
        FestivalWidgetEntry(
            date: .now,
            kind: .upcoming,
            subtitle: "3 Venues",
            subtitleSystemImage: "line.3.horizontal.decrease.circle",
            liveEvents: [],
            upcomingEvents: [
                previewDisplayEvent(
                    id: 101,
                    name: "WDR Big Band feat. Nduduzo Makhathini - The Ntu Sound Chamber Experience",
                    startOffset: 26 * 60 * 60,
                    endOffset: 27.25 * 60 * 60,
                    placeID: 18,
                    venueName: "Buhne Kastellplatz mit sehr langem Namen",
                    status: .upcoming
                ),
                previewDisplayEvent(
                    id: 102,
                    name: "Moritz Simon Geist - TRIPODS ONE PERFORMANCE WITH EXTENDED ROBOTIC PERCUSSION",
                    startOffset: 31 * 60 * 60,
                    endOffset: 32 * 60 * 60,
                    placeID: 24,
                    venueName: "Bollwerk 107",
                    status: .upcoming
                ),
                previewDisplayEvent(
                    id: 103,
                    name: "A Very, Very, Very Long Ensemble Name That Pushes Truncation Hard",
                    startOffset: 36 * 60 * 60,
                    endOffset: 37 * 60 * 60,
                    placeID: 25,
                    venueName: "Repelen Open Air Pavilion",
                    status: .upcoming
                ),
                previewDisplayEvent(
                    id: 104,
                    name: "Dawn Improvisation Session",
                    startOffset: 40 * 60 * 60,
                    endOffset: 41 * 60 * 60,
                    placeID: 26,
                    venueName: "Hall of Mirrors",
                    status: .upcoming
                )
            ],
            emptyMessage: "No upcoming events for the selected venues.",
            nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.minimumRefreshInterval)
        )
    }

    static var previewUpcomingDenseLarge: Self {
        FestivalWidgetEntry(
            date: .now,
            kind: .upcoming,
            subtitle: "All venues",
            subtitleSystemImage: nil,
            liveEvents: [
                previewDisplayEvent(
                    id: 105,
                    name: "Live: Freysinn",
                    startOffset: -8 * 60,
                    endOffset: 20 * 60,
                    placeID: 27,
                    venueName: "Die Rohre",
                    status: .live
                ),
                previewDisplayEvent(
                    id: 106,
                    name: "Live: SORBD",
                    startOffset: -4 * 60,
                    endOffset: 36 * 60,
                    placeID: 18,
                    venueName: "Buhne Kastellplatz",
                    status: .live
                )
            ],
            upcomingEvents: [
                previewDisplayEvent(id: 107, name: "Futur2", startOffset: 40 * 60, endOffset: 95 * 60, placeID: 19, venueName: "Wo die wilden Frosche klatschen", status: .upcoming),
                previewDisplayEvent(id: 108, name: "moers sessions!", startOffset: 65 * 60, endOffset: 120 * 60, placeID: 20, venueName: "Festivalcampus", status: .upcoming),
                previewDisplayEvent(id: 109, name: "Wo die wilden Kinder wohnen", startOffset: 85 * 60, endOffset: 135 * 60, placeID: 21, venueName: "Workshop Tent", status: .upcoming),
                previewDisplayEvent(id: 110, name: "Late Night Procession", startOffset: 110 * 60, endOffset: 160 * 60, placeID: 22, venueName: "Rodelberg", status: .upcoming),
                previewDisplayEvent(id: 111, name: "Sunrise Brass", startOffset: 130 * 60, endOffset: 185 * 60, placeID: 23, venueName: "Schlosspark", status: .upcoming)
            ],
            emptyMessage: "No upcoming events.",
            nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.minimumRefreshInterval)
        )
    }

    static var previewUpcomingEmpty: Self {
        FestivalWidgetEntry(
            date: .now,
            kind: .upcoming,
            subtitle: "2 Venues",
            subtitleSystemImage: "line.3.horizontal.decrease.circle",
            liveEvents: [],
            upcomingEvents: [],
            emptyMessage: "No upcoming events for the selected venues.",
            nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.maximumRefreshInterval)
        )
    }

    static var previewFavoritesChaos: Self {
        FestivalWidgetEntry(
            date: .now,
            kind: .favorites,
            subtitle: "",
            subtitleSystemImage: nil,
            liveEvents: [],
            upcomingEvents: [
                previewDisplayEvent(
                    id: 201,
                    name: "Moritz Simon Geist - TRIPODS ONE PERFORMANCE WITH EXTENDED ROBOTIC PERCUSSION",
                    startOffset: 2 * 60 * 60,
                    endOffset: 3 * 60 * 60,
                    placeID: 31,
                    venueName: "Bollwerk 107",
                    status: .upcoming
                ),
                previewDisplayEvent(
                    id: 202,
                    name: "Futur2",
                    startOffset: 3.5 * 60 * 60,
                    endOffset: 4.5 * 60 * 60,
                    placeID: 32,
                    venueName: "Wo die wilden Frosche klatschen",
                    status: .upcoming
                ),
                previewDisplayEvent(
                    id: 203,
                    name: "Freysinn",
                    startOffset: 5 * 60 * 60,
                    endOffset: 6 * 60 * 60,
                    placeID: 33,
                    venueName: "Die Rohre",
                    status: .upcoming
                ),
                previewDisplayEvent(
                    id: 204,
                    name: "A Favorite With A Name That Needs Aggressive Truncation In Compact Families",
                    startOffset: 6.5 * 60 * 60,
                    endOffset: 7.5 * 60 * 60,
                    placeID: 34,
                    venueName: "Open Air South Stage",
                    status: .upcoming
                )
            ],
            emptyMessage: "No upcoming favorite events yet.",
            nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.minimumRefreshInterval)
        )
    }

    static var previewFavoritesEmpty: Self {
        FestivalWidgetEntry(
            date: .now,
            kind: .favorites,
            subtitle: "",
            subtitleSystemImage: nil,
            liveEvents: [],
            upcomingEvents: [],
            emptyMessage: "No upcoming favorite events yet.",
            nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.maximumRefreshInterval)
        )
    }

}
