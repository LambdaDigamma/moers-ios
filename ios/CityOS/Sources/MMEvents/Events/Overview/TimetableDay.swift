//
//  TimetableDay.swift
//
//
//  Created by Codex on 20.03.26.
//

import Foundation

public struct TimetableDay: Identifiable {
    
    public let date: Date
    public let events: [EventListItemViewModel]
    
    public init(date: Date, events: [EventListItemViewModel]) {
        self.date = date.stripTimeComponent()
        self.events = events
    }
    
    public var id: Date {
        date
    }
    
}
