//
//  AnalyticsManager.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import Crashlytics
import StoreKit

struct AnalyticsManager {
    
    static var shared = AnalyticsManager()
    
    private let kSendAnalytics = "sendAnalytics"
    private let kAppRuns = "kAppRuns"
    private let reviewRate = 5
    
    private var shouldLog = true
    
    init() {
        
        self.shouldLog = isAnalyticsEnabled
        
    }
    
    public var isAnalyticsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kSendAnalytics)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kSendAnalytics)
        }
    }
    
    public var numberOfAppRuns: Int {
        get {
            return UserDefaults.standard.integer(forKey: kAppRuns)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kAppRuns)
        }
    }
    
    public func requestReviewIfNeeded() {
        
        let runs = self.numberOfAppRuns
        
        if runs % reviewRate == 0 && runs >= 5 {
            
            self.requestReview()
            
        }
        
    }
    
    public func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    public func logOpenedPetrolPrices(for place: String) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Petrol Prices", customAttributes: ["place": place])
        }
        
    }
    
    public func logOpenedWasteSchedule() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Waste Schedule", customAttributes: [:])
        }
        
    }
    
    public func logOpenedDashboard() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Dashboard", customAttributes: [:])
        }
        
    }
    
    public func logOpenedNews() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened News", customAttributes: [:])
        }
        
    }
    
    public func logOpenedMaps() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Maps", customAttributes: [:])
        }
        
    }
    
    public func logOpenedEvents() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Events", customAttributes: [:])
        }
        
    }
    
    public func logOpenedEventDetail(_ event: Event) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Event Details", customAttributes: ["name": event.name,
                                                                                        "time": event.parsedTime,
                                                                                        "date": event.date])
        }
        
    }
    
    public func logOpenedOther() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Other", customAttributes: [:])
        }
        
    }
    
    public func logOpenedTheme() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Themes", customAttributes: [:])
        }
        
    }
    
    public func logSelectedTheme(_ theme: Theme) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Selected Theme", customAttributes: ["identifier": theme.identifier])
        }
        
    }
    
    public func logCompletedOnboarding() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Onboarding Completed", customAttributes: [:])
        }
        
    }
    
    public func logSelectedBranch(_ branch: String) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Branch", customAttributes: ["name": branch])
        }
        
    }
    
    public func logSelectedItemContent(_ location: Location) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Selected Location (Drawer)", customAttributes:
                ["location": location.category,
                 "name": location.name])
        }
        
    }
    
    public func logSelectedItem(_ location: Location) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Selected Location", customAttributes:
                ["location": location.category,
                 "name": location.name])
        }
        
    }
    
    public func logSelectedCluster(with memberCount: Int) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Selected Cluster", customAttributes:
                ["count": memberCount])
        }
        
    }
    
    public func logNavigation(_ location: Location) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Navigation", customAttributes:
                ["type": location.category,
                 "name": location.name])
        }
        
    }
    
    public func logPano(_ panoID: PanoID) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Opened Pano", customAttributes: ["id": panoID])
        }
        
    }
    
    public func logUserType(_ type: User.UserType) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Onboarding - User Type", customAttributes: ["type": type.rawValue])
        }
        
    }
    
    public func logEnabledNotifications() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Onboarding - Enabled Notifications", customAttributes: [:])
        }
        
    }
    
    public func logEnabledLocation() {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Onboarding - Enabled Notifications", customAttributes: [:])
        }
        
    }

    public func logPetrolType(_ type: PetrolType) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Onboarding - Petrol Type", customAttributes: ["type": type.rawValue])
        }
        
    }
    
    public func logEnabledRubbishReminder(_ hour: Int) {
        
        if shouldLog {
            Answers.logCustomEvent(withName: "Onboarding - Enabled Reminder", customAttributes: ["hour": hour])
        }
        
    }
    
}
