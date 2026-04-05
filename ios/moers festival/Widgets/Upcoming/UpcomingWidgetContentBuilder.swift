//
//  UpcomingWidgetContentBuilder.swift
//  WidgetsExtension
//
//  Created by Codex on 05.04.26.
//

import Foundation

enum UpcomingWidgetContentBuilder {

    static func build(
        from events: [FestivalWidgetEvent],
        selectedVenueIDs: Set<Int>,
        now: Date = .now
    ) -> FestivalWidgetContent {
        let filteredEvents = events
            .filter(\.hasValidStartDate)
            .filter { event in
                guard !selectedVenueIDs.isEmpty else {
                    return true
                }

                guard let placeID = event.placeID else {
                    return false
                }

                return selectedVenueIDs.contains(placeID)
            }

        return FestivalWidgetTimelineEngine.buildContent(from: filteredEvents, now: now)
    }

}
