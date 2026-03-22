//
//  EventUtilities.swift
//  
//
//  Created by Lennart Fischer on 20.05.22.
//

import Foundation

public enum TimeDisplayMode {
    case none
    case date
    case range
    case relative
    case live
    
    public var title: String {
        switch self {
            case .none:
                return "none"
            case .date:
                return "date"
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
    
    /// Day offset - events after this hour (default 6 AM) belong to the next day.
    /// Events between 0:00 and this hour belong to the previous day.
    public static let defaultDayOffset: TimeInterval = 60 * 60 * 6
    
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
    
    public static func timeDisplayMode(
        startDate: Date?,
        endDate: Date?,
        scheduleDisplayMode: EventScheduleDisplayMode
    ) -> TimeDisplayMode {

        if !scheduleDisplayMode.showsDateComponent {
            return .none
        }

        if !scheduleDisplayMode.showsTimeComponent {
            return startDate == nil ? .none : .date
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
