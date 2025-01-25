//
//  CachedTripDate.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation

public enum CachedTripDate: Codable {
    
    case departure(Date)
    case arrival(Date)
    
    public func toExperience() -> TripDate {
        switch self {
            case .departure(let date):
                return .departure(date)
            case .arrival(let date):
                return .arrival(date)
        }
    }
    
}
