//
//  String+Extensions.swift
//  
//
//  Created by Lennart Fischer on 03.01.21.
//

import Foundation

extension String {
    
    public static func localized(_ key: String) -> String {
        
        return NSLocalizedString(key, comment: "")
        
    }
    
    public static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
}
