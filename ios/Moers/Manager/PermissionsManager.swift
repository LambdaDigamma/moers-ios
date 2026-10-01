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

public class PermissionsManager {
    
    public static let shared = PermissionsManager()
    
    public func requestRemoteNotifications() {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        
        UIApplication.shared.registerForRemoteNotifications()
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
