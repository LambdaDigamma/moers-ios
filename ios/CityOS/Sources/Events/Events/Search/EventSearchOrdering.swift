//
//  EventSearchOrdering.swift
//
//
//  Created by Codex on 20.05.26.
//

import Foundation

public enum EventSearchOrdering {

    public static func sortEventsByDateAndTitle(
        _ lhs: Event,
        _ rhs: Event
    ) -> Bool {

        switch (lhs.startDate, rhs.startDate) {
        case let (lhsDate?, rhsDate?) where lhsDate != rhsDate:
            return lhsDate < rhsDate
        case (.some, nil):
            return true
        case (nil, .some):
            return false
        default:
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

    }

}
