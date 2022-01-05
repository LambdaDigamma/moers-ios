//
//  Date+Extensions.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation

private var stringFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.autoupdatingCurrent
    return dateFormatter
}()

private var fromDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "DE_de") // TODO: Is this right?
    return dateFormatter
}()

public extension Date {
    
    static func from(_ dateString: String, withFormat format: String) -> Date? {
        
        fromDateFormatter.dateFormat = format
        return fromDateFormatter.date(from: dateString)
        
    }
    
    func format(format: String) -> String {
        
        stringFormatter.dateFormat = format
        return stringFormatter.string(from: self)
        
    }
    
}
