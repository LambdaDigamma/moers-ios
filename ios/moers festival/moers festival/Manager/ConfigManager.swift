//
//  ConfigManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 26.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseRemoteConfig

class ConfigManager {
    
    static let shared = ConfigManager()
    
//    public var remoteConfig: RemoteConfig
    
    init() {
        
//        self.remoteConfig = RemoteConfig.remoteConfig()
//        self.remoteConfig.configSettings = RemoteConfigSettings()
//        self.remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
//        self.remoteConfig.activate {  (success, error) in
//
//            if success {
//                self.fetchConfig()
//            }
//
//        }
        
    }
    
    public func fetchConfig() {
        
//        let expirationDuration = 3600.0
        
//        if remoteConfig.configSettings.isDeveloperModeEnabled {
//            expirationDuration = 0.0
//        }
        
//        remoteConfig.fetch(withExpirationDuration: expirationDuration) { (status, error) -> Void in
//            if status == .success {
//                print("Config fetched!")
//                self.remoteConfig.activate(completion: nil)
//                NotificationCenter.default.post(Notification(name: Notification.Name.DidReceiveRemoteConfig))
//            } else {
//                print("Config not fetched")
//                print("Error: \(error?.localizedDescription ?? "No error available.")")
//            }
//        }
        
    }
    
    public var isMapEnabled: Bool {
        return true //remoteConfig["map_is_enabled"].boolValue
    }
    
    public var showTracker: Bool {
        return true
    }
    
    public var numberOfDisplayedUpcomingEvents: Int {
        return 15 // (remoteConfig["number_events_upcoming"].numberValue as? Int) ?? 15
    }
    
}
