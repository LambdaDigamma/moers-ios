//
//  ApplicationServerConfiguration.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

public struct ApplicationServerConfiguration {
    
    public var baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public static var baseURL = ""
    public static var petrolAPIKey: String?
    public static var isMoersFestivalModeEnabled = true
    
    public static func registerBaseURL(_ url: String) {
        self.baseURL = url
    }
    
    public static func registerPetrolAPIKey(_ key: String) {
        self.petrolAPIKey = key
    }
    
}
