//
//  FavoritesWidgetProvider.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import SwiftUI
import WidgetKit
import AppIntents

struct FavoritesWidgetProvider: AppIntentTimelineProvider {

    typealias Intent = FavoritesWidgetIntent
    typealias Entry = FestivalWidgetEntry

    func placeholder(in context: Context) -> FestivalWidgetEntry {
        .previewFavorites
    }

    func snapshot(for configuration: FavoritesWidgetIntent, in context: Context) async -> FestivalWidgetEntry {
        if context.isPreview {
            return .previewFavorites
        }
        return await loadEntry(fallbackToPlaceholder: true)
    }

    func timeline(for configuration: FavoritesWidgetIntent, in context: Context) async -> Timeline<FestivalWidgetEntry> {
        let entry = await loadEntry(fallbackToPlaceholder: false)
        let refreshDate = max(entry.date.addingTimeInterval(FestivalWidgetTimelineEngine.minimumRefreshInterval), entry.nextRefreshDate)
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

    private func loadEntry(fallbackToPlaceholder: Bool) async -> FestivalWidgetEntry {
        let favoriteEventIDs = FestivalWidgetDataStore.loadFavoriteEventIDs()

        guard !favoriteEventIDs.isEmpty else {
            return FestivalWidgetEntry(
                date: .now,
                kind: .favorites,
                subtitle: String(localized: "Upcoming favorite events"),
                subtitleSystemImage: nil,
                liveEvents: [],
                upcomingEvents: [],
                emptyMessage: String(localized: "No upcoming favorite events yet."),
                nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.maximumRefreshInterval)
            )
        }

        do {
            let events = try await FestivalWidgetDataStore.loadEvents()
            let content = FavoritesWidgetContentBuilder.build(
                from: events,
                favoriteEventIDs: favoriteEventIDs
            )

            return FestivalWidgetEntry(
                date: .now,
                kind: .favorites,
                subtitle: String(localized: "\(favoriteEventIDs.count) saved"),
                subtitleSystemImage: nil,
                liveEvents: content.liveEvents,
                upcomingEvents: content.upcomingEvents,
                emptyMessage: String(localized: "No upcoming favorite events yet."),
                nextRefreshDate: content.nextRefreshDate
            )
        } catch {
            return fallbackToPlaceholder ? .previewFavorites : FestivalWidgetEntry(
                date: .now,
                kind: .favorites,
                subtitle: String(localized: "\(favoriteEventIDs.count) saved"),
                subtitleSystemImage: nil,
                liveEvents: [],
                upcomingEvents: [],
                emptyMessage: String(localized: "Unable to load favorite events right now."),
                nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.maximumRefreshInterval)
            )
        }
    }

}