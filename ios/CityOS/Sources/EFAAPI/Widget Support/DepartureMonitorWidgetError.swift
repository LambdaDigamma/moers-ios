//
//  DepartureMonitorWidgetError.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation

public enum DepartureMonitorResult {
    
    case loadingFailed
    case noStationSelected
    case noUpcomingDepartures
    case success([DepartureViewModel])
    
}

public enum DepartureMonitorWidgetError: LocalizedError, Equatable, Hashable {
    
    case loadingFailed
    case noStationSelected
    case noUpcomingDepartures
    
}
