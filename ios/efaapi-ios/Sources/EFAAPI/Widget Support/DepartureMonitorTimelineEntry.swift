//
//  DepartureMonitorTimelineEntry.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

#if canImport(WidgetKit)

import Foundation
import WidgetKit

public struct DepartureMonitorTimelineEntry: TimelineEntry {
    
    public var date: Date
    public var name: String = ""
    public var departures: [DepartureViewModel]
    
    public init(
        date: Date = Date(),
        stationName: String,
        departures: [DepartureViewModel]
    ) {
        self.date = date
        self.name = stationName
        self.departures = departures
    }
    
}

#endif
