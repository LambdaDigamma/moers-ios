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
            .filter(\.hasValidStartDate)
            .filter { favoriteEventIDs.contains($0.id) }

        return FestivalWidgetTimelineEngine.buildContent(from: filteredEvents, now: now)
    }

}
