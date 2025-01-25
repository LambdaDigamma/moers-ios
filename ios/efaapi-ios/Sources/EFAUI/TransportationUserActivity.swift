//
//  TransportationUserActivity.swift
//  
//
//  Created by Lennart Fischer on 10.04.22.
//

import Foundation

public enum TransportationUserActivity {
    
    public static let bundle: String = Bundle.main.bundleIdentifier ?? ""
    
    public enum IDs {
        public static let transportationOverview = {
            return bundle + ".transportation.overview"
        }()
        public static let search = {
            return bundle + ".transportation.search"
        }()
    }
    
    @discardableResult
    public static func configureTransportationOverview(
        for activity: NSUserActivity = .init(activityType: IDs.transportationOverview)
    ) -> NSUserActivity {
        
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.title = "Fahrt planen"
        
        return activity
        
    }
    
    @discardableResult
    public static func configureTransportationSearch(
        for activity: NSUserActivity = .init(activityType: IDs.search),
        origin: String,
        destination: String
    ) -> NSUserActivity {
        
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.title = "Verbindungen für \(origin) nach \(destination)"
        
        return activity
        
    }
    
}

