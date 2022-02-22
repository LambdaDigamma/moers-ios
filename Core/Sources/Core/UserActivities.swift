//
//  UserActivities.swift
//  
//
//  Created by Lennart Fischer on 12.02.22.
//

import Foundation

public enum UserActivities {
    
    public static let bundle: String = "de.okfn.niederrhein.Moers"
    
    public enum IDs {
        public static let rubbishSchedule = {
            return bundle + ".nextRubbish"
        }()
        public static let dashboard = {
            return bundle + ".dashboard"
        }()
    }
    
    public static func dashboardActivity() -> NSUserActivity {
        
        let activity = NSUserActivity(activityType: IDs.dashboard)
        
        activity.isEligibleForHandoff = true
        
        return activity
        
    }
    
}
