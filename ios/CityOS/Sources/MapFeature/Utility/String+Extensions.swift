//
//  String+Extensions.swift
//  
//
//  Created by Lennart Fischer on 22.04.22.
//

import Foundation

internal extension String {
    
    static func localized(_ key: String) -> String {
        return String(localized: String.LocalizationValue(stringLiteral: key), bundle: .module)
    }
    
}
