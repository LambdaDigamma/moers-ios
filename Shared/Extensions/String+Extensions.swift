//
//  String+Extensions.swift
//  Moers
//
//  Created by Lennart Fischer on 30.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

extension String {
    
    static func localized(_ key: String) -> String {
        
        return NSLocalizedString(key, comment: "")
        
    }
    
    var doubleValue: Double {
        
        get {
            
            let s: NSString = self as NSString
            
            return s.doubleValue
            
        }
        
    }
    
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
}
