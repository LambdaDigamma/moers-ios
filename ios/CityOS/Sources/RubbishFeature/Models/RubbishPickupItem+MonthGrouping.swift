//
//  RubbishPickupItem+MonthGrouping.swift
//  
//
//  Created by Lennart Fischer on 02.02.22.
//

import Foundation

public extension Collection where Element == RubbishPickupItem {
    
    func groupByMonths() -> [DateComponents : [RubbishPickupItem]] {
        
        let calendar = Calendar.autoupdatingCurrent
        
        let grouped = Dictionary(grouping: self) { item in
            return calendar.dateComponents([.day, .month, .year], from: item.date)
        }
        
        return grouped
    }
    
    func groupByDayIntoSections() -> [RubbishSection] {
        
        let form = DateFormatter()
        form.doesRelativeDateFormatting = true
        form.dateStyle = .medium
        form.formattingContext = .standalone
        
        return Dictionary(grouping: self) { item in
            item.date
        }
        .sorted(by: { $0.key < $1.key })
        .map { (key: Date, value: [RubbishPickupItem]) in
            return RubbishSection(header: form.string(from: key), items: value)
        }
        
    }
    
}
