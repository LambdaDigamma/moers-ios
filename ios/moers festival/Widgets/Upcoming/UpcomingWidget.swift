//
//  UpcomingWidget.swift
//  WidgetsExtension
//
//  Created by Codex on 05.04.26.
//

import SwiftUI
import WidgetKit
import AppIntents

@available(iOSApplicationExtension 17.0, *)
struct UpcomingWidgetProvider: AppIntentTimelineProvider {

    typealias Intent = UpcomingWidgetIntent
    typealias Entry = FestivalWidgetEntry

    func placeholder(in context: Context) -> FestivalWidgetEntry {
        .previewUpcoming
    }

    func snapshot(for configuration: UpcomingWidgetIntent, in context: Context) async -> FestivalWidgetEntry {
        if context.isPreview {
            return .previewUpcoming
        }
        return await loadEntry(for: configuration, fallbackToPlaceholder: true)
    }

    func timeline(for configuration: UpcomingWidgetIntent, in context: Context) async -> Timeline<FestivalWidgetEntry> {
        let entry = await loadEntry(for: configuration, fallbackToPlaceholder: false)
        let refreshDate = max(entry.date.addingTimeInterval(FestivalWidgetTimelineEngine.minimumRefreshInterval), entry.nextRefreshDate)
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

    private func loadEntry(
        for configuration: UpcomingWidgetIntent,
        fallbackToPlaceholder: Bool
    ) async -> FestivalWidgetEntry {
        do {
            let events = try await FestivalWidgetDataStore.loadEvents()
            let selectedVenues = configuration.venues ?? []
            let selectedVenueIDs = Set(selectedVenues.map(\.id))
            let content = UpcomingWidgetContentBuilder.build(
                from: events,
                selectedVenueIDs: selectedVenueIDs
            )

            return FestivalWidgetEntry(
                date: .now,
                kind: .upcoming,
                subtitle: subtitle(for: selectedVenues),
                liveEvents: content.liveEvents,
                upcomingEvents: content.upcomingEvents,
                emptyMessage: selectedVenueIDs.isEmpty
                    ? "No upcoming events right now."
                    : "No upcoming events for the selected venues.",
                nextRefreshDate: content.nextRefreshDate
            )
        } catch {
            return fallbackToPlaceholder ? .previewUpcoming : FestivalWidgetEntry(
                date: .now,
                kind: .upcoming,
                subtitle: subtitle(for: configuration.venues ?? []),
                liveEvents: [],
                upcomingEvents: [],
                emptyMessage: "Unable to load upcoming events right now.",
                nextRefreshDate: .now.addingTimeInterval(FestivalWidgetTimelineEngine.maximumRefreshInterval)
            )
        }
    }

    private func subtitle(for selectedVenues: [VenueEntity]) -> String {
        switch selectedVenues.count {
        case 0:
            return "All venues"
        case 1:
            return selectedVenues[0].name
        case 2:
            return "\(selectedVenues[0].name) +1"
        default:
            return "\(selectedVenues.count) venues"
        }
    }

}

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    FestivalWidgetEntry.previewUpcoming
}

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemLarge) {
    UpcomingWidget()
} timeline: {
    FestivalWidgetEntry.previewUpcoming
}

@available(iOSApplicationExtension 17.0, *)
struct UpcomingWidget: Widget {

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.upcoming.rawValue,
            intent: UpcomingWidgetIntent.self,
            provider: UpcomingWidgetProvider()
        ) { entry in
            FestivalWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming")
        .description("Live and upcoming moers festival events with an optional venue filter.")
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
