//
//  AppStrings.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

public enum AppStrings {
    
    public static let appName = String(localized: "Mein Moers", bundle: .module)
    
    public enum Menu {
        public static let dashboard = String(localized: "Today", bundle: .module)
        public static let news = String(localized: "News", bundle: .module)
        public static let map = String(localized: "Map", bundle: .module)
        public static let events = String(localized: "Events", bundle: .module)
        public static let other = String(localized: "Other", bundle: .module)
    }
    
    public enum Common {
        public static let okay = "Okay"
        public static let close = String(localized: "Close", bundle: .module)
    }
    
    public static let address = String(localized: "Address", bundle: .module)
    
    public enum OpeningState {
        public static let closed = String(localized: "Closed", bundle: .module)
        public static let open = String(localized: "Open", bundle: .module)
    }
    
    public enum Waste {
        public static let errorMessage = String(localized: "You can enable the waste calendar in the settings.", bundle: .module)
        public static let loadingFailed = String(localized: "Loading the waste calendar could not be completed.", bundle: .module)
        public static let noUpcomingRubbishItems = String(localized: "Loading the waste calendar could not be completed.", bundle: .module)
    }
    
    public enum Buergerfunk {
        public static let title = String(localized: "Community radio", bundle: .module)
        public static let description = String(localized: "Every day between 8 p.m. and 9 p.m. on Radio K.W. (Sundays and holidays from 7:04 p.m.), there is a slightly different kind of radio - community radio. People from the county of Wesel spend many hours of their free time in production studios to send an hour of radio programming over the airwaves every day.", bundle: .module)
        public static let nextBroadcasts = String(localized: "Next broadcasts", bundle: .module)
        public static let contactAction = String(localized: "Contact", bundle: .module)
        public static let disclaimer = String(localized: "The information is supplied by Bürgerfunk Moers. There is no guarantee for correctness or completeness.", bundle: .module)
        public static let allAction = String(localized: "All", bundle: .module)
        public static let listenToPastBroadcasts = String(localized: "Listen to recent broadcasts", bundle: .module)
        public static let unknownTime = String(localized: "Time not known", bundle: .module)
        
        public static let listenNowAction = String(localized: "Listen now", bundle: .module)
        public static let remindMeAction = String(localized: "Remind me", bundle: .module)
        public static let reminderActiveAction = String(localized: "Reminder active", bundle: .module)
        
        public static let disableReminderInfo = String(localized: "Tap again to remove the reminder.", bundle: .module)
        
        public static func notificationBody(title: String) -> String {
            return String(localized: "The radio broadcast «\(title)» starts in five minutes. \nHave fun listening!", bundle: .module)
        }
    }
    
    public enum Directions {
        public static let getDirections = String(localized: "Get directions", bundle: .module)
    }
    
    public enum UserActivities {
        public enum Dashboard {
            public static let title = String(localized: "Show today", bundle: .module)
            public static let invocationPhrase = title
        }
        public enum RubbishSchedule {
            public static let title = String(localized: "Next pick up dates", bundle: .module)
            public static let invocationPhrase = title
            public static let keywords = AppStrings.buildKeywords("Garbage, collection, date, garbage collection")
        }
        public enum ParkingAreaOverview {
            public static let title = String(localized: "Show free sites", bundle: .module)
            public static let invocationPhrase = title
            public static let keywords = AppStrings.buildKeywords("Parking, Car, Driving, City")
        }
        public enum FuelStations {
            public static let title = String(localized: "Fuel stations near you", bundle: .module)
            public static let invocationPhrase = title
            public static let keywords = AppStrings.buildKeywords("Gas stations, prices, proximity, car, Fuel")
        }
        public enum News {
            public static let title = String(localized: "Check latest news", bundle: .module)
            public static let invocationPhrase = title
        }
        public enum Map {
            public static let title = String(localized: "Find location", bundle: .module)
            public static let invocationPhrase = title
        }
        public enum Events {
            public static let title = String(localized: "Show events", bundle: .module)
            public static let invocationPhrase = title
        }
        public enum Settings {
            public static let title = String(localized: "Show settings", bundle: .module)
            public static let invocationPhrase = title
        }
        
    }
    
    public static func buildKeywords(_ key: String) -> Set<String> {
        return Set(
            String(localized: String.LocalizationValue(stringLiteral: key), bundle: .module)
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        )
    }
    
}
