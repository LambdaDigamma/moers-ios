//
//  AnalyticsManager.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import StoreKit
import MMAPI
import MMUI

struct AnalyticsManager {
    
    static var shared = AnalyticsManager()
    
    private let kSendAnalytics = "sendAnalytics"
    private let kAppRuns = "kAppRuns"
    private let reviewRate = 5
    
    private var shouldLog = true
    
    init() {
        
        self.shouldLog = true
        
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
            Analytics.logEvent("Opened Petrol Prices", parameters: ["place": place])
        }
        
    }
    
    public func logOpenedWasteSchedule() {
        
        if shouldLog {
            Analytics.logEvent("Opened Waste Schedule", parameters: [:])
        }
        
    }
    
    public func logOpenedDashboard() {
        
        if shouldLog {
            Analytics.logEvent("Opened_Dashboard", parameters: [:])
        }
        
    }
    
    public func logOpenedNews() {
        
        if shouldLog {
            Analytics.logEvent("Opened News", parameters: [:])
        }
        
    }
    
    public func logOpenedMaps() {
        
        if shouldLog {
            Analytics.logEvent("Opened Maps", parameters: [:])
        }
        
    }
    
    public func logOpenedEvents() {
        
        if shouldLog {
            Analytics.logEvent("Opened Events", parameters: [:])
        }
        
    }
    
    public func logOpenedOther() {
        
        if shouldLog {
            Analytics.logEvent("Opened Other", parameters: [:])
        }
        
    }
    
    public func logOpenedTheme() {
        
        if shouldLog {
            Analytics.logEvent("Opened Themes", parameters: [:])
        }
        
    }
    
    public func logSelectedTheme(_ theme: ApplicationTheme) {
        
        if shouldLog {
            Analytics.logEvent("Selected Theme", parameters: ["identifier": theme.identifier])
        }
        
    }
    
    public func logCompletedOnboarding() {
        
        if shouldLog {
            Analytics.logEvent("Onboarding Completed", parameters: [:])
        }
        
    }
    
    public func logSelectedBranch(_ branch: String) {
        
        if shouldLog {
            Analytics.logEvent("Branch", parameters: ["name": branch])
        }
        
    }
    
    public func logSelectedItemContent(_ location: Location) {
        
        if shouldLog {
            Analytics.logEvent("Selected Location (Drawer)", parameters:
                ["location": location.category,
                 "name": location.name])
        }
        
    }
    
    public func logSelectedItem(_ location: Location) {
        
        if shouldLog {
            Analytics.logEvent("Selected Location", parameters:
                ["location": location.category,
                 "name": location.name])
        }
        
    }
    
    public func logSelectedCluster(with memberCount: Int) {
        
        if shouldLog {
            Analytics.logEvent("Selected Cluster", parameters:
                ["count": memberCount])
        }
        
    }
    
    public func logNavigation(_ location: Location) {
        
        if shouldLog {
            Analytics.logEvent("Navigation", parameters:
                ["type": location.category,
                 "name": location.name])
        }
        
    }
    
    public func logPano(_ panoID: PanoID) {
        
        if shouldLog {
            Analytics.logEvent("Opened Pano", parameters: ["id": panoID])
        }
        
    }
    
    public func logUserType(_ type: User.UserType) {
        
        if shouldLog {
            Analytics.logEvent("Onboarding - User Type", parameters: ["type": type.rawValue])
        }
        
    }
    
    public func logEnabledNotifications() {
        
        if shouldLog {
            Analytics.logEvent("Onboarding - Enabled Notifications", parameters: [:])
        }
        
    }
    
    public func logEnabledLocation() {
        
        if shouldLog {
            Analytics.logEvent("Onboarding - Enabled Notifications", parameters: [:])
        }
        
    }

    public func logPetrolType(_ type: PetrolType) {
        
        if shouldLog {
            Analytics.logEvent("Onboarding - Petrol Type", parameters: ["type": type.rawValue])
        }
        
    }
    
    public func logEnabledRubbishReminder(_ hour: Int) {
        
        if shouldLog {
            Analytics.logEvent("Onboarding - Enabled Reminder", parameters: ["hour": hour])
        }
        
    }
    
}
