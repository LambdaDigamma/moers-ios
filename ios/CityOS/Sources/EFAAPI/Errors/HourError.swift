//
//  HourError.swift
//  EFAAPI
//
//  Created by Lennart Fischer on 10.02.20.
//

import Foundation

public enum HourError: Int, Codable, LocalizedError {
    
    case invalidTime = -1
    case hourOutOfRange = -10
    case minuteOutOfRange = -20
    
    public var errorDescription: String? {
        switch self {
            case .invalidTime:
                return "The provided time is invalid."
            case .hourOutOfRange:
                return "The provided hour is out of range."
            case .minuteOutOfRange:
                return "The provided minute is out of range."
        }
    }
    
}
