//
//  EventFilterOption.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation
import Events

nonisolated enum EventFilterOption: Hashable {
    case date(EventDateScope)
    case favorites
    case withImages
    case free
    case attendanceMode(String)
    case category(String)
    case venue(String)
    case organizer(String)

    var title: String {
        switch self {
        case .date(let scope):
            return scope.title
        case .favorites:
            return String(localized: "Favorites")
        case .withImages:
            return String(localized: "With Images")
        case .free:
            return String(localized: "Free")
        case .attendanceMode(let mode):
            return EventAttendanceMode.title(for: mode)
        case .category(let category):
            return category
        case .venue(let venue):
            return venue
        case .organizer(let organizer):
            return organizer
        }
    }
}
