//
//  String+Extensions.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

extension String {
    
    public static func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: .module, value: "", comment: "")
    }
    
}
