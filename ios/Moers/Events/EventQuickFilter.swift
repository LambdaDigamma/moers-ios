//
//  EventQuickFilter.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit
import Events

nonisolated enum EventQuickFilter: CaseIterable, Hashable {
    case today
    case tomorrow
    case nextSevenDays
    case weekend
    case withImages
    case favorites
    case free
    case online

    var title: String {
        switch self {
        case .today:
            return String(localized: "Today")
        case .tomorrow:
            return String(localized: "Tomorrow")
        case .nextSevenDays:
            return String(localized: "7 Days")
        case .weekend:
            return String(localized: "Weekend")
        case .withImages:
            return String(localized: "With Images")
        case .favorites:
            return String(localized: "Favorites")
        case .free:
            return String(localized: "Free")
        case .online:
            return String(localized: "Online")
        }
    }

    var systemImageName: String {
        switch self {
        case .today:
            return "sun.max"
        case .tomorrow:
            return "calendar"
        case .nextSevenDays:
            return "calendar.badge.clock"
        case .weekend:
            return "sparkles"
        case .withImages:
            return "photo"
        case .favorites:
            return "heart"
        case .free:
            return "tag"
        case .online:
            return "video"
        }
    }

    func isSelected(in filter: EventFilter) -> Bool {
        switch self {
        case .today:
            return filter.dateScope == .today
        case .tomorrow:
            return filter.dateScope == .tomorrow
        case .nextSevenDays:
            return filter.dateScope == .nextSevenDays
        case .weekend:
            return filter.dateScope == .weekend
        case .withImages:
            return filter.onlyWithImages
        case .favorites:
            return filter.onlyFavorites
        case .free:
            return filter.onlyFree
        case .online:
            return filter.attendanceModes.contains(EventAttendanceMode.online.rawValue)
        }
    }
}
