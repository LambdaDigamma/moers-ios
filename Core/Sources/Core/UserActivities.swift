//
//  UserActivities.swift
//  
//
//  Created by Lennart Fischer on 12.02.22.
//

import Foundation

public enum UserActivities {
    
    public static let baseURL: URL = URL(string: "https://moers.app")!
    public static let bundle: String = "de.okfn.niederrhein.Moers"
    
    public enum IDs {
        public static let dashboard = {
            return bundle + ".dashboard"
        }()
        public static let rubbishSchedule = {
            return bundle + ".nextRubbish"
        }()
        public static let fuelStations = {
            return bundle + ".fuelStations"
        }()
        public static let newsOverview = {
            return bundle + ".newsOverview"
        }()
        public static let map = {
            return bundle + ".map"
        }()
        public static let events = {
            return bundle + ".events"
        }()
        public static let other = {
            return bundle + ".other"
        }()
        public static let settings = {
            return bundle + ".other.settings"
        }()
    }
    
    @discardableResult
    public static func configureDashboardActivity(
        for activity: NSUserActivity = .init(activityType: IDs.dashboard)
    ) -> NSUserActivity {
        
        activity.isEligibleForHandoff = true
        activity.webpageURL = baseURL.appendingPathComponent("dashboard")
        activity.title = AppStrings.UserActivities.Dashboard.title
        
        return activity
        
    }
    
    @discardableResult
    public static func configureRubbishScheduleActivity(
        for activity: NSUserActivity = .init(activityType: IDs.rubbishSchedule)
    ) -> NSUserActivity {
        
        
        activity.title = AppStrings.UserActivities.RubbishSchedule.title
        activity.suggestedInvocationPhrase = AppStrings.UserActivities.RubbishSchedule.title
        activity.persistentIdentifier = IDs.rubbishSchedule
        activity.keywords = AppStrings.UserActivities.RubbishSchedule.keywords
        activity.isEligibleForPublicIndexing = true
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        
        return activity
        
    }
    
    @discardableResult
    public static func configureFuelStations(
        for activity: NSUserActivity = .init(activityType: IDs.fuelStations)
    ) -> NSUserActivity {
        
        activity.title = AppStrings.UserActivities.FuelStations.title
        activity.suggestedInvocationPhrase = AppStrings.UserActivities.FuelStations.invocationPhrase
        activity.persistentIdentifier = IDs.fuelStations
        activity.keywords = AppStrings.UserActivities.FuelStations.keywords
        activity.isEligibleForPublicIndexing = true
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        
        return activity
        
    }
    
    @discardableResult
    public static func configureNewsList(
        for activity: NSUserActivity = .init(activityType: IDs.newsOverview)
    ) -> NSUserActivity {
        
        activity.isEligibleForHandoff = true
        activity.webpageURL = baseURL.appendingPathComponent("news")
        activity.title = AppStrings.UserActivities.News.title
        
        return activity
        
    }
    
    @discardableResult
    public static func configureEvents(
        for activity: NSUserActivity = .init(activityType: IDs.events)
    ) -> NSUserActivity {
        
        activity.isEligibleForHandoff = true
        activity.webpageURL = baseURL.appendingPathComponent("events")
        activity.title = AppStrings.UserActivities.Events.title
        
        return activity
        
    }
    
    @discardableResult
    public static func configureOther(
        for activity: NSUserActivity = .init(activityType: IDs.other)
    ) -> NSUserActivity {
        
        activity.isEligibleForHandoff = true
        activity.webpageURL = baseURL.appendingPathComponent("other")
        
        return activity
        
    }
    
    @discardableResult
    public static func configureSettings(
        for activity: NSUserActivity = .init(activityType: IDs.settings)
    ) -> NSUserActivity {
        
        activity.isEligibleForHandoff = true
        activity.webpageURL = baseURL.appendingPathComponent("other")
        activity.title = AppStrings.UserActivities.Settings.title
        
        return activity
        
    }
    
}

public enum UserActivity {
    
    public static var current: NSUserActivity? {
        didSet {
            current?.becomeCurrent()
        }
    }
    
}
