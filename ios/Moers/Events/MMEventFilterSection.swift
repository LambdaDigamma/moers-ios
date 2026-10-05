//
//  MMEventFilterSection.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation

nonisolated enum MMEventFilterSection: Int, CaseIterable {
    case date
    case flags
    case attendance
    case categories
    case venues
    case organizers

    var title: String {
        switch self {
        case .date:
            return String(localized: "Date Range")
        case .flags:
            return String(localized: "Display")
        case .attendance:
            return String(localized: "Attendance")
        case .categories:
            return String(localized: "Categories")
        case .venues:
            return String(localized: "Venues")
        case .organizers:
            return String(localized: "Organizers")
        }
    }
}
