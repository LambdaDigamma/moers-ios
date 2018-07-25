//
//  PermissionsManager.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class PermissionsManager {
    
    static let shared = PermissionsManager()
    
    func requestRemoteNotifications() {
        
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            
        } else {
            
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(settings)
            
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
    }
    
}
