//
//  String+Extensions.swift
//  
//
//  Created by Lennart Fischer on 15.12.21.
//

import Foundation

internal extension String {
    
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: .module, value: "", comment: "")
    }
    
}
