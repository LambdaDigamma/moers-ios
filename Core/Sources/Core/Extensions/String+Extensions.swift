//
//  String+Extensions.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

public extension String {
    
    internal static func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: .module, value: "", comment: "")
    }
    
    var isEmptyOrWhitespace: Bool {
        return isEmpty ? true : trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isNotEmptyOrWhitespace: Bool {
        return !isEmptyOrWhitespace
    }
    
    var doubleValue: Double {
        
        get {
            let s: NSString = self as NSString
            return s.doubleValue
        }
        
    }
    
    static func rowToArray(_ string: String?) -> [Int] {
        
        let row = string ?? ""
        
        let items = row
            .replacingOccurrences(of: "\"", with: "")
            .components(separatedBy: ",")
            .compactMap({ Int($0.trimmingCharacters(in: .whitespaces)) })
        
        return items
        
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(startIndex, offsetBy: value.lowerBound)...]
        }
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data,
                                          options: [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding:String.Encoding.utf8.rawValue
                                          ],
                                          documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
}
