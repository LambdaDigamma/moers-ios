//
//  Date+Extensions.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import os

// MARK: - DateFormatter Cache

/// State wrapper that opts out of Sendable checking; thread-safety is enforced by `OSAllocatedUnfairLock`.
private struct _FormatterCacheState: @unchecked Sendable {
    var formatters: [String: DateFormatter] = [:]
}

/// Thread-safe cache for `DateFormatter` instances, keyed by format string and locale identifier.
/// Avoids the expense of creating a new `DateFormatter` on every call.
/// Note: The cache is unbounded; in practice, the number of distinct format/locale combinations
/// used within the app is small, so unbounded growth is not a concern here.
private let _dateFormatterCacheLock = OSAllocatedUnfairLock<_FormatterCacheState>(initialState: .init())

private func _cachedDateFormatter(dateFormat: String, locale: Locale) -> DateFormatter {
    let cacheKey = "\(dateFormat)|\(locale.identifier)"
    return _dateFormatterCacheLock.withLock { state in
        if let cached = state.formatters[cacheKey] {
            return cached
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = dateFormat
        state.formatters[cacheKey] = formatter
        return formatter
    }
}

public extension Date {

    // MARK: - Private Constants

    private static let _deLocale = Locale(identifier: "DE_de")

    // MARK: - Formatting

    func format(format: String) -> String {
        let formatter = _cachedDateFormatter(dateFormat: format, locale: .autoupdatingCurrent)
        return formatter.string(from: self)
    }

    static func from(_ dateString: String, withFormat format: String) -> Date? {
        let formatter = _cachedDateFormatter(dateFormat: format, locale: _deLocale) // TODO: Is this right?
        return formatter.date(from: dateString)
    }
    
    func beautify(format: String = "E dd.MM.yyyy") -> String {
        
        var beautifiedDate = self.format(format: format)
        
        if isToday {
            beautifiedDate = "\(String(localized: "Today", bundle: .module)), \(beautifiedDate)"
        } else if isTomorrow {
            beautifiedDate = "\(String(localized: "Tomorrow", bundle: .module)), \(beautifiedDate)"
        }
        
        return beautifiedDate
        
    }
    
    static func component(_ component: Calendar.Component, from date: Date) -> Int {
        
        let calendar = Calendar.current
        let comp = calendar.component(component, from: date)
        
        return comp
        
    }
    
    var isToday: Bool {
        return Calendar.autoupdatingCurrent.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        return Calendar.autoupdatingCurrent.isDateInTomorrow(self)
    }
    
    static var yesterday: Date {
        
        let calendar = Calendar.autoupdatingCurrent
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())
        
        return yesterday ?? Date()
        
    }
    
    static var somedayInFuture: Date {
        return Date(timeIntervalSinceNow: pow(10, 10))
    }
    
    func isInBeforeInterval(minutes: Double) -> Bool {
        
        let timeInterval = Date().timeIntervalSince(self).rounded()
        
        return timeInterval < 0 && timeInterval >= -minutes * 60
        
    }
    
    func minuteInterval() -> Int {
        
        let timeInterval = abs(Date().timeIntervalSince(self).rounded() / 60)
        
        return Int(timeInterval)
        
    }
    
    func timeAgo() -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        
        return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
        
    }
    
    func accessibleString(dateStyle: DateFormatter.Style = .full, timeStyle: DateFormatter.Style = .none) -> String {
        return DateFormatter.localizedString(from: self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
    
}
