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
                subtitleSystemImage: subtitleSystemImage(for: selectedVenues),
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
                subtitleSystemImage: subtitleSystemImage(for: configuration.venues ?? []),
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
            return "1 Venue"
        default:
            return "\(selectedVenues.count) Venues"
        }
    }

    private func subtitleSystemImage(for selectedVenues: [VenueEntity]) -> String? {
        selectedVenues.isEmpty ? nil : "line.3.horizontal.decrease.circle"
    }

}

@available(iOSApplicationExtension 17.0, *)
#Preview("Upcoming / Small / Baseline", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    FestivalWidgetEntry.previewUpcoming
}

@available(iOSApplicationExtension 17.0, *)
#Preview("Upcoming / Small / Filtered Stress", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    FestivalWidgetEntry.previewUpcomingFilteredChaos
}

@available(iOSApplicationExtension 17.0, *)
#Preview("Upcoming / Medium / Dense", as: .systemMedium) {
    UpcomingWidget()
} timeline: {
    FestivalWidgetEntry.previewUpcomingFilteredChaos
    FestivalWidgetEntry.previewUpcoming
}

@available(iOSApplicationExtension 17.0, *)
#Preview("Upcoming / Large / Dense Timeline", as: .systemLarge) {
    UpcomingWidget()
} timeline: {
    FestivalWidgetEntry.previewUpcomingDenseLarge
    FestivalWidgetEntry.previewUpcomingFilteredChaos
    FestivalWidgetEntry.previewUpcomingEmpty
}

@available(iOSApplicationExtension 17.0, *)
#Preview("Upcoming / Accessory Rectangular", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    FestivalWidgetEntry.previewUpcomingFilteredChaos
}

@available(iOSApplicationExtension 17.0, *)
#Preview("Upcoming / Accessory Inline", as: .accessoryInline) {
    UpcomingWidget()
} timeline: {
    FestivalWidgetEntry.previewUpcoming
}

@available(iOSApplicationExtension 17.0, *)
#Preview("Upcoming / Accessory Circular", as: .accessoryCircular) {
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
//            .accessoryInline,
//            .accessoryRectangular,
//            .accessoryCircular
        ])
    }

}
