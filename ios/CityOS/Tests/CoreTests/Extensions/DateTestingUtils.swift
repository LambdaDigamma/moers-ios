//
//  DateTestingUtils.swift
//  
//
//  Created by Lennart Fischer on 01.10.21.
//

import Foundation

extension Date {
 
    /// Stubs a date from a string with the format `yyyy-MM-dd HH:mm:ss`.
    internal static func stub(from dateString: String) -> Self {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.date(from: dateString) else {
            fatalError("Failed to create date.")
        }
        
        return date
        
    }
    
}
