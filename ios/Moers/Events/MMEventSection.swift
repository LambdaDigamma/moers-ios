//
//  MMEventSection.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation

nonisolated enum MMEventSection: Hashable {
    case loading
    case quickFilters
    case spotlights
    case today
    case tomorrow
    case nextDays
    case future
    case empty

    var title: String? {
        switch self {
        case .loading, .quickFilters, .empty:
            return nil
        case .spotlights:
            return String(localized: "Spotlight")
        case .today:
            return String(localized: "Today")
        case .tomorrow:
            return String(localized: "Tomorrow")
        case .nextDays:
            return String(localized: "Upcoming")
        case .future:
            return String(localized: "Later")
        }
    }
}
