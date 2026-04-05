//
//  FavoritesWidget.swift
//  WidgetsExtension
//
//  Created by Codex on 05.04.26.
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
                subtitle: "Upcoming favorite events",
                liveEvents: [],
                upcomingEvents: [],
                emptyMessage: "No upcoming favorite events yet.",
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
                subtitle: "\(favoriteEventIDs.count) saved",
                liveEvents: content.liveEvents,
                upcomingEvents: content.upcomingEvents,
                emptyMessage: "No upcoming favorite events yet.",
                nextRefreshDate: content.nextRefreshDate
            )
        } catch {
            return fallbackToPlaceholder ? .previewFavorites : FestivalWidgetEntry(
                date: .now,
                kind: .favorites,
                subtitle: "\(favoriteEventIDs.count) saved",
                liveEvents: [],
                upcomingEvents: [],
                emptyMessage: "Unable to load favorite events right now.",
                nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.maximumRefreshInterval)
            )
        }
    }

}

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemSmall) {
    FavoritesWidget()
} timeline: {
    FestivalWidgetEntry.previewFavorites
}

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .accessoryRectangular) {
    FavoritesWidget()
} timeline: {
    FestivalWidgetEntry.previewFavorites
}

@available(iOSApplicationExtension 17.0, *)
struct FavoritesWidget: Widget {

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.favorites.rawValue,
            intent: FavoritesWidgetIntent.self,
            provider: FavoritesWidgetProvider()
        ) { entry in
            FestivalWidgetView(entry: entry)
        }
        .configurationDisplayName("Favorites")
        .description("Your live and upcoming favorite moers festival events.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryInline,
            .accessoryRectangular,
            .accessoryCircular
        ])
    }

}
