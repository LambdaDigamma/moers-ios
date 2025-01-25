//
//  DepartureMonitorData.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import Foundation

public struct DepartureMonitorData {
    
    public var date: Date
    public var name: String = ""
    public var departures: [DepartureViewModel]
    
    public init(date: Date, name: String, departures: [DepartureViewModel]) {
        self.date = date
        self.name = name
        self.departures = departures
    }
    
}
