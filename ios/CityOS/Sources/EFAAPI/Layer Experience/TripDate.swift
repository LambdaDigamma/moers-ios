//
//  TripDate.swift
//  
//
//  Created by Lennart Fischer on 27.12.22.
//

import Foundation

public enum TripDate: Codable {
    
    case departure(Date)
    case arrival(Date)
    
    public func toCached() -> CachedTripDate {
        switch self {
            case .departure(let date):
                return .departure(date)
            case .arrival(let date):
                return .arrival(date)
        }
    }
    
    public func toRaw() -> TripDateTimeType {
        switch self {
            case .departure(_):
                return .departure
            case .arrival(_):
                return .arrival
        }
    }
    
    public var date: Date {
        switch self {
            case .departure(let date):
                return date
            case .arrival(let date):
                return date
        }
    }
    
}
