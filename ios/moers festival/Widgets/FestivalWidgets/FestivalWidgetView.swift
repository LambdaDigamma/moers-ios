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

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            homeScreenCard(maxRows: 3, grouped: false)
        case .systemMedium:
            homeScreenCard(maxRows: 5, grouped: false)
        case .systemLarge:
            homeScreenCard(maxRows: 8, grouped: true)
        case .accessoryInline:
            accessoryInline
        case .accessoryRectangular:
            accessoryRectangular
        case .accessoryCircular:
            accessoryCircular
        default:
            homeScreenCard(maxRows: 5, grouped: false)
        }
    }

    private func homeScreenCard(maxRows: Int, grouped: Bool) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                FestivalWidgetHeader(
                    title: entry.kind.title,
                    subtitle: entry.subtitle
                )

                if entry.allEvents.isEmpty {
                    EventsEmptyState(message: entry.emptyMessage)
                } else if grouped {
                    groupedContent(maxRows: maxRows)
                } else {
                    listContent(entryRows: Array(entry.allEvents.prefix(maxRows)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(for: .widget) {
            FestivalWidgetBackground()
        }
        .widgetURL(entry.primaryURL)
    }

    private func groupedContent(maxRows: Int) -> some View {
        let live = Array(entry.liveEvents.prefix(3))
        let remainingCount = max(0, maxRows - live.count)
        let upcoming = Array(entry.upcomingEvents.prefix(remainingCount))

        return VStack(alignment: .leading, spacing: 10) {
            if !live.isEmpty {
                FestivalWidgetSection(title: "Live", accent: .live) {
                    listContent(entryRows: live)
                }
            }

            if !upcoming.isEmpty {
                FestivalWidgetSection(title: "Next", accent: .upcoming) {
                    listContent(entryRows: upcoming)
                }
            }
        }
    }

    private func listContent(entryRows: [FestivalWidgetDisplayEvent]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entryRows) { row in
                Link(destination: WidgetConstants.eventURL(for: row.event.id)) {
                    FestivalWidgetRow(event: row)
                }
            }
        }
    }

    private var accessoryInline: some View {
        Group {
            if let firstEvent = entry.allEvents.first {
                Link(destination: WidgetConstants.eventURL(for: firstEvent.event.id)) {
                    if firstEvent.status == .live {
                        Text("LIVE \(firstEvent.event.name)")
                    } else if let startDate = firstEvent.event.startDate {
                        Text("\(startDate, format: .dateTime.hour().minute()) \(firstEvent.event.name)")
                    } else {
                        Text(firstEvent.event.name)
                    }
                }
            } else {
                Text(entry.kind == .upcoming ? "No upcoming events" : "No favorite events")
            }
        }
    }

    private var accessoryRectangular: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.kind.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

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
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
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
                        .foregroundStyle(.primary)
                } else if let startDate = firstEvent.event.startDate {
                    Text(startDate, format: .dateTime.hour())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                    Text(startDate, format: .dateTime.minute())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                    Text(String(firstEvent.event.venueName.prefix(1)))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: entry.kind == .favorites ? "heart" : "calendar")
                    .font(.system(size: 16, weight: .semibold))
                Text("0")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .widgetURL(entry.primaryURL)
    }

}
