//
//  DateUtils.swift
//  
//
//  Created by Lennart Fischer on 04.05.23.
//

import Foundation

public extension Date {
    
    func stripTimeComponent() -> Date {
        return DateUtils.stripTimeComponent(from: self)
    }
    
}

public enum DateUtils {
    
    public static func stripTimeComponent(from date: Date) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
    
    /// Strips all time components from the dates so that
    /// each date is only returned once. The result is sorted at the end.
    public static func sortedUniqueDates(_ dates: [Date]) -> [Date] {
        
        let uniqueSet = Set(dates.map { $0.stripTimeComponent() })
        
        return Array(uniqueSet).sorted()
        
    }
    
    /// Calculates the range of a whole date shifted by a specific
    /// time interval offset. This allows events to start at 01AM of
    /// the next day but still to be treated as the same day.
    public static func calculateDateRange(
        for date: Date,
        offset: TimeInterval,
        calendar: Calendar = Calendar.autoupdatingCurrent
    ) -> (startDate: Date, endDate: Date) {
        
        // Get the start of the day for the given date
        let startOfDay = calendar.startOfDay(for: date)
        
        // Add the offset to the start of the day to get the start date of the range
        let startDate = calendar.date(byAdding: .second, value: Int(offset), to: startOfDay)!
        
        // Add the offset plus 24 hours to the start of the day to get the end date of the range
        let endDate = calendar.date(byAdding: .second, value: Int(offset) + 86400, to: startOfDay)!
        
        return (startDate, endDate)
    }
    
    
}
