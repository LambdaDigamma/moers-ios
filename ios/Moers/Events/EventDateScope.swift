//
//  EventDateScope.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation

nonisolated enum EventDateScope: String, CaseIterable, Hashable {
    case all
    case today
    case tomorrow
    case nextSevenDays
    case weekend

    var title: String {
        switch self {
        case .all:
            return String(localized: "All")
        case .today:
            return String(localized: "Today")
        case .tomorrow:
            return String(localized: "Tomorrow")
        case .nextSevenDays:
            return String(localized: "7 Days")
        case .weekend:
            return String(localized: "Weekend")
        }
    }

    var tokenTitle: String? {
        self == .all ? nil : title
    }
}
