//
//  Bundle+Extensions.swift
//  
//
//  Created by Lennart Fischer on 03.01.21.
//

import Foundation

extension Bundle {
    
    private var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    private var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    public var bundleID: String {
        return Bundle.main.bundleIdentifier?.lowercased() ?? ""
    }
    
    public var versionString: String {
        var scheme = ""
        
        if bundleID.contains(".dev") {
            scheme = "Dev"
        } else if bundleID.contains(".staging") {
            scheme = "Staging"
        }
        
        let returnValue = "Version \(releaseVersionNumber) (\(buildVersionNumber)) \(scheme)"
        
        return returnValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
