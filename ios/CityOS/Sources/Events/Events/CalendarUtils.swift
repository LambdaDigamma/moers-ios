//
//  CalendarUtils.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation

enum CalendarUtils {
    
    static func dateToRequiredComponents(day: Date) -> DateComponents {
        
        let calendar = Calendar.autoupdatingCurrent
        
        return calendar.dateComponents([.day, .month, .year], from: day)
        
    }
    
    static func componentsToDate(_ components: DateComponents) -> Date? {
        
        let calendar = Calendar.autoupdatingCurrent
        
        return calendar.date(from: components)
        
    }
    
}
