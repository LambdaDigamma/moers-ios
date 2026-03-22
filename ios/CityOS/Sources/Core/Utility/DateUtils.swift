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
    
    private static let nightTimeOffset: TimeInterval = 60 * 60 * 6 // 6 hours
    
    public static func stripTimeComponent(from date: Date) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
    
    /// Returns the effective calendar day for an event, accounting for night-time events
    /// that should be grouped with the previous day (e.g., events between 00:00-06:00
    /// belong to the previous day for festival scheduling purposes).
    public static func effectiveCalendarDay(for date: Date) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        let hour = calendar.component(.hour, from: date)
        
        // If event is between 00:00 and 06:00, count it towards the previous day
        if hour < 6 {
            return calendar.date(byAdding: .day, value: -1, to: stripTimeComponent(from: date)) ?? date
        }
        
        return stripTimeComponent(from: date)
    }
    
    /// Strips all time components from the dates so that
    /// each date is only returned once. The result is sorted at the end.
    public static func sortedUniqueDates(_ dates: [Date]) -> [Date] {
        
        let uniqueSet = Set(dates.map { effectiveCalendarDay(for: $0) })
        
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
        // This means the "day" actually starts at offset time (e.g., 4 AM)
        let startDate = calendar.date(byAdding: .second, value: Int(offset), to: startOfDay)!
        
        // Add the offset plus 24 hours to the start of the day to get the end date of the range
        let endDate = calendar.date(byAdding: .second, value: Int(offset) + 86400, to: startOfDay)!
        
        return (startDate, endDate)
    }
    
    /// Calculates the date range for an event's effective calendar day.
    /// This properly handles night-time events (0-6 AM) that belong to the previous day.
    /// Default offset is 4 hours (14400 seconds) - the time after midnight when a new day starts.
    public static func effectiveDateRange(
        for date: Date,
        offset: TimeInterval = 14400,
        calendar: Calendar = Calendar.autoupdatingCurrent
    ) -> (startDate: Date, endDate: Date) {
        
        let effectiveDay = effectiveCalendarDay(for: date)
        return calculateDateRange(for: effectiveDay, offset: offset, calendar: calendar)
        
    }
    
    
}
