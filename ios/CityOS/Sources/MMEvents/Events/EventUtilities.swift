//
//  EventUtilities.swift
//  
//
//  Created by Lennart Fischer on 20.05.22.
//

import Foundation

public enum TimeDisplayMode: Equatable, Sendable {
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
    
    public static func isActive(
        startDate: Date?,
        endDate: Date?,
        now: Date = Date()
    ) -> Bool {

        guard let startDate,
              let effectiveEndDate = Self.effectiveEndDate(
                  startDate: startDate,
                  endDate: endDate
              ) else {
            return false
        }

        return startDate <= now && now < effectiveEndDate

    }
    
    public static func dateRange(startDate: Date?, endDate: Date?) -> ClosedRange<Date>? {
        
        if let startDate,
           let effectiveEndDate = Self.effectiveEndDate(
               startDate: startDate,
               endDate: endDate
           ) {
            return startDate...effectiveEndDate
        }
        
        return nil
        
    }
    
    public static func timeDisplayMode(
        startDate: Date?,
        endDate: Date?,
        scheduleDisplayMode: EventScheduleDisplayMode,
        now: Date = Date()
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
        
        let timeInterval = startDate.timeIntervalSince(now)
        
        if timeInterval > 60 * 60 {
            return .range
        } else if timeInterval <= 60 * 60 && timeInterval > 0 {
            return .relative
        } else if Self.isActive(startDate: startDate, endDate: endDate, now: now) {
            return .live
        } else {
            return .range
        }
        
    }

    static func effectiveEndDate(startDate: Date?, endDate: Date?) -> Date? {
        guard let startDate else {
            return nil
        }

        if let endDate, endDate > startDate {
            return endDate
        }

        return startDate.addingTimeInterval(Self.defaultTimeInterval)
    }

    static func nextTimeDisplayUpdateDate(
        startDate: Date?,
        endDate: Date?,
        scheduleDisplayMode: EventScheduleDisplayMode,
        after date: Date
    ) -> Date? {
        guard scheduleDisplayMode.showsDateComponent,
              scheduleDisplayMode.showsTimeComponent,
              let startDate else {
            return nil
        }

        let relativeStartDate = startDate.addingTimeInterval(-60 * 60)

        if date < relativeStartDate {
            return relativeStartDate
        }

        if date < startDate {
            return min(Self.nextMinute(after: date), startDate)
        }

        guard let effectiveEndDate = Self.effectiveEndDate(
            startDate: startDate,
            endDate: endDate
        ) else {
            return nil
        }

        if date < effectiveEndDate {
            return effectiveEndDate
        }

        return nil
    }

    static func nextMinute(after date: Date) -> Date {
        Date(
            timeIntervalSince1970: floor(date.timeIntervalSince1970 / 60) * 60 + 60
        )
    }

    static func relativeTimeText(startDate: Date, now: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.dateTimeStyle = .numeric

        if let remainingMinutes = Self.remainingCountdownMinutes(
            startDate: startDate,
            now: now
        ) {
            let roundedStartDate = now.addingTimeInterval(TimeInterval(remainingMinutes * 60))

            return formatter.localizedString(for: roundedStartDate, relativeTo: now)
        }

        return formatter.localizedString(for: startDate, relativeTo: now)
    }

    static func remainingCountdownMinutes(startDate: Date, now: Date) -> Int? {
        let timeInterval = startDate.timeIntervalSince(now)

        guard timeInterval > 0 else {
            return nil
        }

        return max(1, Int(ceil(timeInterval / 60)))
    }
    
}
