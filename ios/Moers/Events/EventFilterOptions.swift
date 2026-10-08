//
//  EventFilterOptions.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation
import Events

nonisolated struct EventFilterOptions: Equatable {
    let categories: [String]
    let venues: [String]
    let organizers: [String]
    let attendanceModes: [String]
    let supportsFreeFilter: Bool

    init(events: [Event]) {
        categories = Self.unique(events.compactMap(\.category))
        venues = Self.unique(events.compactMap { EventFormatter.location(for: $0) })
        organizers = Self.unique(events.compactMap { EventFormatter.organizer(for: $0) })
        supportsFreeFilter = events.contains { $0.extras?.isFree != nil }
        attendanceModes = Self.unique(events.compactMap(\.resolvedAttendanceMode))
    }

    private static func unique(_ values: [String]) -> [String] {
        Array(Set(values.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }))
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
}
