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
            return "Zeitraum"
        case .flags:
            return "Ansicht"
        case .attendance:
            return "Teilnahme"
        case .categories:
            return "Kategorien"
        case .venues:
            return "Orte"
        case .organizers:
            return "Veranstalter"
        }
    }
}
