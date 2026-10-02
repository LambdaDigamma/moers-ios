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
            return "Im Fokus"
        case .today:
            return "Heute"
        case .tomorrow:
            return "Morgen"
        case .nextDays:
            return "In den nächsten Tagen"
        case .future:
            return "Später"
        }
    }
}
