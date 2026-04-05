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
            .filter { event in
                guard let startDate = event.startDate else {
                    return false
                }

                if event.showsTimeComponent {
                    return true
                }

                // Date-only preview entries should appear as upcoming before they start,
                // but should never turn into "live" items once their day begins.
                return startDate > now
            }
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
