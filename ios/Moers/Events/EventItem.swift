//
//  EventItem.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation
import Events

nonisolated enum EventItem: Hashable {
    case loading
    case quickFilter(EventQuickFilter)
    case spotlight(Event)
    case event(Event)
    case empty(title: String, message: String)

    static func == (lhs: EventItem, rhs: EventItem) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.quickFilter(let lhsFilter), .quickFilter(let rhsFilter)):
            return lhsFilter == rhsFilter
        case (.spotlight(let lhsEvent), .spotlight(let rhsEvent)):
            return lhsEvent.id == rhsEvent.id
        case (.event(let lhsEvent), .event(let rhsEvent)):
            return lhsEvent.id == rhsEvent.id
        case (.empty(let lhsTitle, let lhsMessage), .empty(let rhsTitle, let rhsMessage)):
            return lhsTitle == rhsTitle && lhsMessage == rhsMessage
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .loading:
            hasher.combine(0)
        case .quickFilter(let quickFilter):
            hasher.combine(1)
            hasher.combine(quickFilter)
        case .spotlight(let event):
            hasher.combine(2)
            hasher.combine(event.id)
        case .event(let event):
            hasher.combine(3)
            hasher.combine(event.id)
        case .empty(let title, let message):
            hasher.combine(4)
            hasher.combine(title)
            hasher.combine(message)
        }
    }
}
