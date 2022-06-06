//
//  MMAPIConfig.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import ModernNetworking

@available(*, deprecated, message: "This has been moved to MMCommon")
public struct MMAPIConfig {
    
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
