//
//  MMEventQuickFilter.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit

nonisolated enum MMEventQuickFilter: CaseIterable, Hashable {
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
            return "Heute"
        case .tomorrow:
            return "Morgen"
        case .nextSevenDays:
            return "7 Tage"
        case .weekend:
            return "Wochenende"
        case .withImages:
            return "Mit Bildern"
        case .favorites:
            return "Favoriten"
        case .free:
            return "Kostenlos"
        case .online:
            return "Online"
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

    func isSelected(in filter: MMEventFilter) -> Bool {
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
            return filter.attendanceModes.contains(MMEventAttendanceMode.online.rawValue)
        }
    }
}
