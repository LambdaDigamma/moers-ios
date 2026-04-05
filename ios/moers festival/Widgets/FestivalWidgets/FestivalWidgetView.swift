//
//  FestivalWidgetView.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit


struct FestivalWidgetView: View {

    let entry: FestivalWidgetEntry

    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallWidgetCard
        case .systemMedium:
            homeScreenCard(maxRows: mediumMaxRows, grouped: false, compactRows: true)
        case .systemLarge:
            homeScreenCard(maxRows: 6, grouped: true, compactRows: false)
        case .accessoryInline:
            accessoryInline
        case .accessoryRectangular:
            accessoryRectangular
        case .accessoryCircular:
            accessoryCircular
        default:
            homeScreenCard(maxRows: 3, grouped: false, compactRows: true)
        }
    }

    private var mediumMaxRows: Int {
        dynamicTypeSize >= .xxLarge ? 2 : 3
    }

    private var smallWidgetCard: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(entry.kind.title)
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 0)

                if let featuredEvent = smallFeaturedEvent {
                    smallHeroEvent(featuredEvent)
                } else {
                    smallEmptyState
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(for: .widget) {
            FestivalWidgetBackground()
        }
        .clipShape(ContainerRelativeShape())
        .widgetURL(entry.primaryURL)
        .preferredColorScheme(.dark)
    }

    private var smallFeaturedEvent: FestivalWidgetDisplayEvent? {
        entry.upcomingEvents.first ?? entry.liveEvents.first
    }

    private func homeScreenCard(maxRows: Int, grouped: Bool, compactRows: Bool) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: compactRows ? 8 : 10) {
                FestivalWidgetHeader(
                    title: entry.kind.title,
                    subtitle: entry.subtitle,
                    subtitleSystemImage: entry.subtitleSystemImage
                )

                if entry.allEvents.isEmpty {
                    EventsEmptyState(message: entry.emptyMessage)
                } else if grouped {
                    groupedContent(maxRows: maxRows, compactRows: compactRows)
                } else {
                    listContent(entryRows: Array(entry.allEvents.prefix(maxRows)), compactRows: compactRows)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(for: .widget) {
            FestivalWidgetBackground()
        }
        .clipShape(ContainerRelativeShape())
        .widgetURL(entry.primaryURL)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func smallHeroEvent(_ event: FestivalWidgetDisplayEvent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if event.status == .live {
                HStack(spacing: 5) {
                    Circle()
                        .fill(WidgetColors.live)
                        .frame(width: 7, height: 7)

                    Text("LIVE")
                        .font(.system(.caption2, design: .default))
                        .fontWeight(.bold)
                        .foregroundStyle(WidgetColors.live)
                }
            } else if let startDate = event.event.startDate {
                Text("Next \(startDate, format: .dateTime.hour().minute())")
                    .font(.caption.monospacedDigit())
                    .fontWeight(.bold)
                    .foregroundStyle(WidgetColors.upcoming)
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(event.event.name)
                    .font(.system(.body, design: .default))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)

                Text(event.event.venueName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(1)

                if event.status == .live, let endDate = event.event.endDate, endDate > .now {
                    Text("until \(endDate, format: .dateTime.hour().minute())")
                        .font(.caption2.monospaced())
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var smallEmptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: entry.kind == .favorites ? "heart.slash" : "calendar.badge.exclamationmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(entry.kind == .favorites ? Color.white : WidgetColors.upcoming)

            Text(entry.emptyMessage)
                .font(.system(.footnote, design: .default))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func groupedContent(maxRows: Int, compactRows: Bool) -> some View {
        let liveLimit = compactRows ? 2 : 3
        let live = Array(entry.liveEvents.prefix(liveLimit))
        let remainingCount = max(0, maxRows - live.count)
        let upcoming = Array(entry.upcomingEvents.prefix(remainingCount))

        return VStack(alignment: .leading, spacing: compactRows ? 8 : 10) {
            if !live.isEmpty {
                FestivalWidgetSection(title: "Live", accent: .live) {
                    listContent(entryRows: live, compactRows: compactRows)
                }
            }

            if !upcoming.isEmpty {
                FestivalWidgetSection(title: "Next", accent: .upcoming) {
                    listContent(entryRows: upcoming, compactRows: compactRows)
                }
            }
        }
    }

    private func listContent(entryRows: [FestivalWidgetDisplayEvent], compactRows: Bool) -> some View {
        VStack(alignment: .leading, spacing: compactRows ? 6 : 8) {
            ForEach(entryRows) { row in
                Link(destination: WidgetConstants.eventURL(for: row.event.id)) {
                    FestivalWidgetRow(event: row, isCompact: compactRows)
                }
            }
        }
    }

    private var accessoryInline: some View {
        Group {
            if let firstEvent = entry.allEvents.first {
                Link(destination: WidgetConstants.eventURL(for: firstEvent.event.id)) {
                    if firstEvent.status == .live {
                        Text("Live now: \(firstEvent.event.name)")
                    } else if let startDate = firstEvent.event.startDate {
                        Text("Next \(startDate, format: .dateTime.hour().minute()) \(firstEvent.event.name)")
                    } else {
                        Text(firstEvent.event.name)
                    }
                }
            } else {
                Text(entry.kind == .upcoming ? "No upcoming events" : "No favorite events")
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private var accessoryRectangular: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let firstEvent = entry.allEvents.first {
                Link(destination: WidgetConstants.eventURL(for: firstEvent.event.id)) {
                    VStack(alignment: .leading, spacing: 4) {
                        FestivalCompactStatusLine(event: firstEvent)
                        Text(firstEvent.event.name)
                            .font(.footnote.weight(.semibold))
                            .lineLimit(2)
                        Text(firstEvent.event.venueName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            } else {
                Text(entry.emptyMessage)
                    .font(.caption)
                    .foregroundStyle(WidgetColors.mutedText)
                    .lineLimit(3)
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
        .widgetURL(entry.primaryURL)
    }

    private var accessoryCircular: some View {
        VStack(spacing: 2) {
            if let firstEvent = entry.allEvents.first {
                if firstEvent.status == .live {
                    Text("LIVE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetColors.live)
                    Circle()
                        .fill(WidgetColors.live)
                        .frame(width: 10, height: 10)
                    Text("\(entry.allEvents.count)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(WidgetColors.primaryText)
                } else if let startDate = firstEvent.event.startDate {
                    Image(systemName: entry.kind == .favorites ? "heart.fill" : "calendar")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(WidgetColors.mutedText)
                    Text(startDate, format: .dateTime.hour())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetColors.primaryText)
                    Text(startDate, format: .dateTime.minute())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetColors.primaryText)
                    Text(String(firstEvent.event.venueName.prefix(1)))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(WidgetColors.mutedText)
                }
            } else {
                Image(systemName: entry.kind == .favorites ? "heart" : "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WidgetColors.primaryText)
                Text("0")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.mutedText)
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
        .widgetURL(entry.primaryURL)
    }

}
