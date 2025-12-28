//
//  FirebaseFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import Foundation
import AppScaffold
import Firebase
import FirebaseMessaging
import UIKit

class FirebaseFrameworkConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
        ConfigManager.shared.fetchConfig()
        
    }
    
}
