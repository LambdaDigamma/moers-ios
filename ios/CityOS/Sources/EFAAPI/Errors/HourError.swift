//
//  HourError.swift
//  EFAAPI
//
//  Created by Lennart Fischer on 10.02.20.
//

import Foundation

nonisolated public enum HourError: Int, Codable, LocalizedError {
    
    case invalidTime = -1
    case hourOutOfRange = -10
    case minuteOutOfRange = -20
    
    public var errorDescription: String? {
        switch self {
            case .invalidTime:
                return String(localized: "The provided time is invalid.", bundle: .module)
            case .hourOutOfRange:
                return String(localized: "The provided hour is out of range.", bundle: .module)
            case .minuteOutOfRange:
                return String(localized: "The provided minute is out of range.", bundle: .module)
        }
    }
    
}
