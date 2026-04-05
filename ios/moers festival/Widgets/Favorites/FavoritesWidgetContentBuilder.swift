//
//  FavoritesWidgetContentBuilder.swift
//  WidgetsExtension
//
//  Created by Codex on 05.04.26.
//

import Foundation

enum FavoritesWidgetContentBuilder {

    static func build(
        from events: [FestivalWidgetEvent],
        favoriteEventIDs: Set<Int>,
        now: Date = .now
    ) -> FestivalWidgetContent {
        guard !favoriteEventIDs.isEmpty else {
            return FestivalWidgetContent(
                liveEvents: [],
                upcomingEvents: [],
                nextRefreshDate: now.addingTimeInterval(FestivalWidgetTimelineEngine.maximumRefreshInterval)
            )
        }

        let filteredEvents = events
            .filter { event in
                guard favoriteEventIDs.contains(event.id), let startDate = event.startDate else {
                    return false
                }

                if event.showsTimeComponent {
                    return true
                }

                // Keep future date-only preview entries visible in favorites,
                // but never surface them as live once the event day starts.
                return startDate > now
            }

        return FestivalWidgetTimelineEngine.buildContent(from: filteredEvents, now: now)
    }

}
