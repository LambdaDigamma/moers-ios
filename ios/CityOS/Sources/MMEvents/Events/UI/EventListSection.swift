//
//  EventListSection.swift
//
//
//  Created by Codex on 20.05.26.
//

import Foundation

public struct EventListSection: Identifiable {

    public let id: String
    public let title: String
    public let effectiveDay: Date?
    public let events: [EventListItemViewModel]

    public init(
        id: String,
        title: String,
        effectiveDay: Date?,
        events: [EventListItemViewModel]
    ) {
        self.id = id
        self.title = title
        self.effectiveDay = effectiveDay
        self.events = events
    }

}
