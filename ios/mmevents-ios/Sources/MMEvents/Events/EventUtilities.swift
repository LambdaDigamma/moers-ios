//
//  EventUtilities.swift
//  
//
//  Created by Lennart Fischer on 20.05.22.
//

import Foundation

public enum TimeDisplayMode {
    case none
    case range
    case relative
    case live
    
    public var title: String {
        switch self {
            case .none:
                return "none"
            case .range:
                return "range"
            case .relative:
                return "relative"
            case .live:
                return "live"
        }
    }
    
}

public enum EventUtilities {
    
    public static let defaultTimeInterval: TimeInterval = 30 * 60
    
    public static let defaultDayOffset: TimeInterval = 60 * 60 * 4
    
    public static func isActive(startDate: Date?, endDate: Date?) -> Bool {
        
        // TODO: Check this
        
        if let startDate = startDate, let endDate = endDate, startDate <= endDate {
            return (startDate...endDate).contains(Date())
        } else if let startDate = startDate {
            let autocalculatedEndDate = startDate.addingTimeInterval(Self.defaultTimeInterval)
            return (startDate...autocalculatedEndDate).contains(Date())
        }
        
        return false
        
    }
    
    public static func dateRange(startDate: Date?, endDate: Date?) -> ClosedRange<Date>? {
        
        if let startDate = startDate {
            
            let endDate = endDate ?? startDate.addingTimeInterval(Self.defaultTimeInterval)
            
            if endDate <= startDate {
                return startDate...startDate.addingTimeInterval(Self.defaultTimeInterval)
            }
            
            return startDate...endDate
        }
        
        return nil
        
    }
    
    public static func timeDisplayMode(startDate: Date?, endDate: Date?, isPreview: Bool) -> TimeDisplayMode {
        
        if isPreview {
            return .none
        }
        
        guard let startDate = startDate else {
            return .none
        }
        
        let timeInterval = startDate.timeIntervalSince(Date())
        
        if timeInterval > 60 * 60 {
            return .range
        } else if timeInterval < 60 * 60 && timeInterval > 0 {
            return .relative
        } else if Self.isActive(startDate: startDate, endDate: endDate) {
            return .live
        } else {
            return .range
        }
        
    }
    
}
