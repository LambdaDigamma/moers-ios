//
//  MMEventDateScope.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation

nonisolated enum MMEventDateScope: String, CaseIterable, Hashable {
    case all
    case today
    case tomorrow
    case nextSevenDays
    case weekend

    var title: String {
        switch self {
        case .all:
            return "Alle"
        case .today:
            return "Heute"
        case .tomorrow:
            return "Morgen"
        case .nextSevenDays:
            return "7 Tage"
        case .weekend:
            return "Wochenende"
        }
    }

    var tokenTitle: String? {
        self == .all ? nil : title
    }
}
