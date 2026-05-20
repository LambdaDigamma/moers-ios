//
//  PermissionsManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import UserNotifications
import OSLog

class PermissionsManager {
    
    static let shared = PermissionsManager()
    
    func requestRemoteNotifications() {
        
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
                if let error {
                    Logger(.default).error("Notification authorization failed: \(error.localizedDescription)")
                }

                guard granted else {
                    return
                }

                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    FestivalNotificationTopicSynchronizer.shared.sync()
                }
            }
            
        } else {
            
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            
        }
    }
    
}
