//
//  Environment.swift
//  
//
//  Created by Lennart Fischer on 03.01.21.
//

import Foundation

@MainActor
public enum Environment {
    
    public enum Keys {
        enum Plist {
            static let rootURL = "ROOT_URL"
            static let clientSecret = "CLIENT_SECRET"
        }
    }
    
    internal static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    public static let rootURL: String = {
        guard let rootURLstring = Environment.infoDictionary[Keys.Plist.rootURL] as? String else {
            fatalError("Root URL not set in plist for this environment")
        }
        return rootURLstring
    }()
    
    public static let clientSecret: String = {
        guard let apiKey = Environment.infoDictionary[Keys.Plist.clientSecret] as? String else {
            fatalError("API Key not set in plist for this environment")
        }
        return apiKey
    }()
    
}
