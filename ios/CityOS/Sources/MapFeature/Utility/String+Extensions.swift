//
//  String+Extensions.swift
//  
//
//  Created by Lennart Fischer on 22.04.22.
//

import Foundation

internal extension String {
    
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: .module, value: "", comment: "")
    }
    
}
