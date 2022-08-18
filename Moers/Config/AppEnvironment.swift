//
//  AppEnvironment.swift
//  Moers
//
//  Created by Lennart Fischer on 30.09.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import ModernNetworking

public enum AppEnvironment {
    
    enum Keys {
        enum Plist {
            static let baseURL = "BASE_URL"
            static let rootURL = "ROOT_URL"
            static let clientSecret = "CLIENT_SECRET"
            static let clientID = "CLIENT_ID"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let baseURL: String = {
        guard let baseURLstring = AppEnvironment.infoDictionary[Keys.Plist.baseURL] as? String else {
            fatalError("Base URL not set in plist for this environment")
        }
        return baseURLstring
    }()
    
    static let rootURL: String = {
        guard let rootURLstring = AppEnvironment.infoDictionary[Keys.Plist.rootURL] as? String else {
            fatalError("Root URL not set in plist for this environment")
        }
        return rootURLstring
    }()
    
    static let clientSecret: String = {
        guard let clientSecret = AppEnvironment.infoDictionary[Keys.Plist.clientSecret] as? String else {
            fatalError("API Key not set in plist for this environment")
        }
        return clientSecret
    }()
    
    static let clientID: Int = {
        guard let clientIDString = AppEnvironment.infoDictionary[Keys.Plist.clientID] as? String else {
            fatalError("API Key not set in plist for this environment")
        }
        return (clientIDString as NSString).integerValue
    }()
    
}
