//
//  PackageStrings.swift
//  DashboardFeature
//
//  Created by Lennart Fischer on 11.02.22.
//

import Foundation

internal extension String {
    
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: .module, value: "", comment: "")
    }
    
}

internal enum PackageStrings {
    
    internal enum Dashboard {
        internal static let title = String.localized("Dashboard.title")
    }
    
}
