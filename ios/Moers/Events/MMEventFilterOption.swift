//
//  MMEventFilterOption.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation

nonisolated enum MMEventFilterOption: Hashable {
    case date(MMEventDateScope)
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
            return "Favoriten"
        case .withImages:
            return "Mit Bildern"
        case .free:
            return "Kostenlos"
        case .attendanceMode(let mode):
            return MMEventAttendanceMode(rawValue: mode)?.title ?? mode
        case .category(let category):
            return category
        case .venue(let venue):
            return venue
        case .organizer(let organizer):
            return organizer
        }
    }
}
