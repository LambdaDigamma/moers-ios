//
//  String+Extensions.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

extension String {

    internal static func localized(_ key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle.module, value: "", comment: "")
    }
    
}
