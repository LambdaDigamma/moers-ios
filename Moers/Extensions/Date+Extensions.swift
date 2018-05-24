//
//  Date+Extensions.swift
//  Moers
//
//  Created by Lennart Fischer on 24.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

extension Date {
    
    func format(format: String) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "DE_de")
        dateFormatter.dateFormat = format
        let date = dateFormatter.string(from: self)
        
        return date
        
    }
    
    static func from(_ dateString: String, withFormat format: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "DE_de")
        
        let date = dateFormatter.date(from: dateString)
        
        return date
        
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
        
        let day = Date.component(.day, from: self)
        let month = Date.component(.month, from: self)
        let year = Date.component(.year, from: self)
        
        let today = Date()
        
        return day == Date.component(.day, from: today) &&
               month == Date.component(.month, from: today) &&
               year == Date.component(.year, from: today)
        
    }
    
    var isTomorrow: Bool {
        
        let day = Date.component(.day, from: self)
        let month = Date.component(.month, from: self)
        let year = Date.component(.year, from: self)
        
        let today = Date()
        
        return day == Date.component(.day, from: today) + 1 &&
            month == Date.component(.month, from: today) &&
            year == Date.component(.year, from: today)
        
    }
    
}
