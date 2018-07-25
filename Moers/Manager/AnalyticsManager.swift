//
//  AnalyticsManager.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct AnalyticsManager {
    
    static var shared = AnalyticsManager()
    
    private let kSendAnalytics = "sendAnalytics"
    
    public var isAnalyticsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kSendAnalytics)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kSendAnalytics)
        }
    }
    
}
