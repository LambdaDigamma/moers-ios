//
//  String+Extensions.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

public extension String {
    
    nonisolated var isEmptyOrWhitespace: Bool {
        return isEmpty ? true : trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    nonisolated var isNotEmptyOrWhitespace: Bool {
        return !isEmptyOrWhitespace
    }
    
    nonisolated var doubleValue: Double {
        
        get {
            let s: NSString = self as NSString
            return s.doubleValue
        }
        
    }
    
    nonisolated static func rowToArray(_ string: String?) -> [Int] {
        
        let row = string ?? ""
        
        let items = row
            .replacingOccurrences(of: "\"", with: "")
            .components(separatedBy: ",")
            .compactMap({ Int($0.trimmingCharacters(in: .whitespaces)) })
        
        return items
        
    }
    
    nonisolated subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    nonisolated subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    nonisolated subscript(value: PartialRangeFrom<Int>) -> Substring {
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
