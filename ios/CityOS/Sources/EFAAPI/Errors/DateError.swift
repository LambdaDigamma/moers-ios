//
//  DateError.swift
//  EFAAPI
//
//  Created by Lennart Fischer on 10.02.20.
//

import Foundation

public enum DateError: Int, Codable, LocalizedError {
    
    case invalidDate = -1
    case yearOutOfRange = -10
    case monthOutOfRange = -20
    case dayOutOfRange = -30
    case dateOutsideOfSchedulePeriod = -4001
    
    public var errorDescription: String? {
        
        switch self {
            case .invalidDate:
                return "The provided date is invalid."
            case .yearOutOfRange:
                return "Thr provided year is out of range."
            case .monthOutOfRange:
                return "The provided month is out of range."
            case .dayOutOfRange:
                return "The provided day is out of range."
            case .dateOutsideOfSchedulePeriod:
                return "The provided date is out of the schedule period."
        }
        
    }
    
}
