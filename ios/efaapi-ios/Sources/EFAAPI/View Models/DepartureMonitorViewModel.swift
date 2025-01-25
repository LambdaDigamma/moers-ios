//
//  DepartureMonitorViewModel.swift
//  
//
//  Created by Lennart Fischer on 08.12.21.
//

import Foundation

public class DepartureMonitorViewModel: ObservableObject {
    
    public let stationName: String
    public let date: Date
    public let departures: [DepartureViewModel]
    
    public init(
        stationName: String,
        departures: [DepartureViewModel],
        date: Date = Date()
    ) {
        self.stationName = stationName
        self.departures = departures
        self.date = date
    }
    
}
