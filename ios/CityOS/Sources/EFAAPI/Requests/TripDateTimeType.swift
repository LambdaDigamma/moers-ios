//
//  TripDateTimeType.swift
//  
//
//  Created by Lennart Fischer on 08.04.22.
//

import Foundation

nonisolated public enum TripDateTimeType: String, CaseIterable {
    
    case departure = "dep"
    case arrival = "arr"
    
    public var name: String {
        switch self {
            case .departure:
                return String(localized: "Departure time", bundle: .module)
            case .arrival:
                return String(localized: "Arrival time", bundle: .module)
        }
    }
    
}
