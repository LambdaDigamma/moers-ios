//
//  AppStrings.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

public enum AppStrings {
    
    public static let appName = String.localized("AppName")
    
    public enum Waste {
        public static let errorMessage = String.localized("Waste.errorMessage")
        public static let loadingFailed = String.localized("Waste.loadingFailed")
        public static let noUpcomingRubbishItems = String.localized("Waste.noUpcomingRubbishItems")
    }
    
    public enum Buergerfunk {
        public static let title = String.localized("Buergerfunk.title")
        public static let description = String.localized("Buergerfunk.description")
        public static let nextBroadcasts = String.localized("Buergerfunk.nextBroadcasts")
        public static let contactAction = String.localized("Buergerfunk.contactAction")
        public static let disclaimer = String.localized("Buergerfunk.disclaimer")
        public static let allAction = String.localized("Buergerfunk.allAction")
        public static let listenToPastBroadcasts = String.localized("Buergerfunk.listenToPastBroadcasts")
        public static let unknownTime = String.localized("Buergerfunk.unknownTime")
        
        public static let listenNowAction = String.localized("Buergerfunk.listenNowAction")
        public static let remindMeAction = String.localized("Buergerfunk.remindMeAction")
        public static let reminderActiveAction = "Erinnerung aktiv" // String.localized("")
        
        public static let disableReminderInfo = String.localized("Buergerfunk.disableReminderInfo")
    }
    
    public enum Directions {
        public static let getDirections = String.localized("Directions.getDirections")
    }
    
}
