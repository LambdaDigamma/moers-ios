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
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error {
                Logger(.default).error("Notification authorization failed: \(error.localizedDescription)")
            }

            guard granted else {
                return
            }

            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()
                FestivalNotificationTopicSynchronizer.shared.sync()
            }
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
