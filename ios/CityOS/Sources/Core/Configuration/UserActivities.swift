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
        public static let parkingAreasOverview = {
            return bundle + ".parkingAreasOverview"
        }()
        public static let parkingAreaDetail = {
            return bundle + ".parkingAreaDetail"
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
        public static let transportationOverview = {
            return bundle + ".transportation.overview"
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
#if !os(tvOS)
        activity.persistentIdentifier = IDs.rubbishSchedule
        activity.isEligibleForPrediction = true
#endif
        activity.keywords = AppStrings.UserActivities.RubbishSchedule.keywords
        activity.isEligibleForPublicIndexing = true
        activity.isEligibleForSearch = true
        
        return activity
        
    }
    
    @discardableResult
    public static func configureParkingAreaOverviewActivity(
        for activity: NSUserActivity = .init(activityType: IDs.parkingAreasOverview)
    ) -> NSUserActivity {
        
        activity.title = AppStrings.UserActivities.ParkingAreaOverview.title
#if !os(tvOS)
        activity.persistentIdentifier = IDs.parkingAreasOverview
        activity.isEligibleForPrediction = true
#endif
        activity.keywords = AppStrings.UserActivities.ParkingAreaOverview.keywords
        activity.isEligibleForPublicIndexing = true
        activity.isEligibleForSearch = true
        
        return activity
        
    }
    
    @discardableResult
    public static func configureParkingAreaDetailsActivity(
        for activity: NSUserActivity = .init(activityType: IDs.parkingAreaDetail)
    ) -> NSUserActivity {
        
        activity.title = AppStrings.UserActivities.ParkingAreaOverview.title
#if !os(tvOS)
        activity.persistentIdentifier = IDs.parkingAreaDetail
        activity.isEligibleForPrediction = true
#endif
        activity.keywords = AppStrings.UserActivities.ParkingAreaOverview.keywords
        activity.isEligibleForPublicIndexing = true
        activity.isEligibleForSearch = true
        
        return activity
        
    }
    
    @discardableResult
    public static func configureFuelStations(
        for activity: NSUserActivity = .init(activityType: IDs.fuelStations)
    ) -> NSUserActivity {
        
        activity.title = AppStrings.UserActivities.FuelStations.title
#if !os(tvOS)
        activity.persistentIdentifier = IDs.fuelStations
        activity.isEligibleForPrediction = true
#endif
        activity.keywords = AppStrings.UserActivities.FuelStations.keywords
        activity.isEligibleForPublicIndexing = true
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

@MainActor
public enum UserActivity {

    public static var current: NSUserActivity? {
        didSet {
            current?.becomeCurrent()
        }
    }

}
