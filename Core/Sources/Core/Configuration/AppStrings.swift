//
//  AppStrings.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

public enum AppStrings {
    
    public static let appName = String.localized("AppName")
    
    public enum Menu {
        public static let dashboard = String.localized("Menu.dashboard")
        public static let news = String.localized("Menu.news")
        public static let map = String.localized("Menu.map")
        public static let events = String.localized("Menu.events")
        public static let other = String.localized("Menu.other")
    }
    
    public enum Common {
        public static let okay = "Okay"
    }
    
    public static let address = String.localized("Address")
    
    public enum OpeningState {
        public static let closed = String.localized("OpeningState.closed")
        public static let open = String.localized("OpeningState.open")
    }
    
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
        
        public static func notificationBody(title: String) -> String {
            return String.localizedStringWithFormat(String.localized("Buergerfunk.notificationBody"), title)
        }
    }
    
    public enum Directions {
        public static let getDirections = String.localized("Directions.getDirections")
    }
    
    public enum UserActivities {
        public enum Dashboard {
            public static let title = String.localized("UserActivities.Dashboard.title")
            public static let invocationPhrase = title
        }
        public enum RubbishSchedule {
            public static let title = String.localized("UserActivities.RubbishSchedule.title")
            public static let invocationPhrase = title
            public static let keywords = AppStrings.buildKeywords("UserActivities.RubbishSchedule.keywords")
        }
        public enum ParkingAreaOverview {
            public static let title = String.localized("UserActivities.ParkingAreaOverview.title")
            public static let invocationPhrase = title
            public static let keywords = AppStrings.buildKeywords("UserActivities.ParkingAreaOverview.keywords")
        }
        public enum FuelStations {
            public static let title = String.localized("UserActivities.FuelStations.title")
            public static let invocationPhrase = title
            public static let keywords = AppStrings.buildKeywords("UserActivities.FuelStations.keywords")
        }
        public enum News {
            public static let title = String.localized("UserActivities.News.title")
            public static let invocationPhrase = title
        }
        public enum Map {
            public static let title = String.localized("UserActivities.Map.title")
            public static let invocationPhrase = title
        }
        public enum Events {
            public static let title = String.localized("UserActivities.Events.title")
            public static let invocationPhrase = title
        }
        public enum Settings {
            public static let title = String.localized("UserActivities.Settings.title")
            public static let invocationPhrase = title
        }
        
    }
    
    public static func buildKeywords(_ key: String) -> Set<String> {
        return Set(
            String
                .localized(key)
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        )
    }
    
}
