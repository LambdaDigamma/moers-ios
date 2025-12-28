//
//  PermissionsManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseMessaging

class PermissionsManager {
    
    static let shared = PermissionsManager()
    
    func requestRemoteNotifications() {
        
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            
            Messaging.messaging().subscribe(toTopic: "all")
            
        } else {
            
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(settings)
            
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
    }
    
}
