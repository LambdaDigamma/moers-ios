//
//  Date+Extensions.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation

fileprivate var stringFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.autoupdatingCurrent
    return dateFormatter
}()

fileprivate var fromDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "DE_de") // TODO: Is this right?
    return dateFormatter
}()

public extension Date {
    
    func format(format: String) -> String {
        
        stringFormatter.dateFormat = format
        return stringFormatter.string(from: self)
        
    }
    
    static func from(_ dateString: String, withFormat format: String) -> Date? {
        
        fromDateFormatter.dateFormat = format
        return fromDateFormatter.date(from: dateString)
        
    }
    
    func beautify(format: String = "E dd.MM.yyyy") -> String {
        
        var beautifiedDate = self.format(format: format)
        
        if isToday {
            beautifiedDate = "\(String.localized("Today")), \(beautifiedDate)"
        } else if isTomorrow {
            beautifiedDate = "\(String.localized("Tomorrow")), \(beautifiedDate)"
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
