//
//  MMEventFilterOptions.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation
import MMEvents

nonisolated struct MMEventFilterOptions: Equatable {
    let categories: [String]
    let venues: [String]
    let organizers: [String]
    let attendanceModes: [String]

    init(events: [Event]) {
        categories = Self.unique(events.compactMap(\.category))
        venues = Self.unique(events.compactMap { MMEventFormatter.location(for: $0) })
        organizers = Self.unique(events.compactMap { MMEventFormatter.organizer(for: $0) })
        attendanceModes = Self.unique(events.compactMap(\.attendanceMode))
    }

    private static func unique(_ values: [String]) -> [String] {
        Array(Set(values.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }))
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
}
