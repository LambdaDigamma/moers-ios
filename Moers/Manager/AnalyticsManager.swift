//
//  AnalyticsManager.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import StoreKit
import MMAPI
import MMUI
import FuelFeature
import MapFeature

struct AnalyticsManager {
    
    static var shared = AnalyticsManager()
    
    private let kSendAnalytics = "sendAnalytics"
    private let kAppRuns = "kAppRuns"
    private let reviewRate = 5
    
    #if DEBUG
    private var shouldLog = false
    #else
    private var shouldLog = true
    #endif
    
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
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    public func logOpenedPetrolPrices(for place: String) {
        
        if shouldLog {
            Analytics.logEvent("Opened_Petrol_Prices", parameters: ["place": place])
        }
        
    }
    
    public func logOpenedWasteSchedule() {
        
        if shouldLog {
            Analytics.logEvent("Opened_Waste_Schedule", parameters: [:])
        }
        
    }
    
    public func logOpenedDashboard() {
        
        if shouldLog {
            Analytics.logEvent("Opened_Dashboard", parameters: [:])
        }
        
    }
    
    public func logOpenedNews() {
        
        if shouldLog {
            Analytics.logEvent("Opened_News", parameters: [:])
        }
        
    }
    
    public func logOpenedMaps() {
        
        if shouldLog {
            Analytics.logEvent("Opened_Maps", parameters: [:])
        }
        
    }
    
    public func logOpenedEvents() {
        
        if shouldLog {
            Analytics.logEvent("Opened_Events", parameters: [:])
        }
        
    }
    
    public func logOpenedOther() {
        
        if shouldLog {
            Analytics.logEvent("Opened_Other", parameters: [:])
        }
        
    }
    
    public func logOpenedTheme() {
        
        if shouldLog {
            Analytics.logEvent("Opened_Themes", parameters: [:])
        }
        
    }
    
    public func logSelectedTheme(_ theme: ApplicationTheme) {
        
        if shouldLog {
            Analytics.logEvent("Selected_Theme", parameters: ["identifier": theme.identifier])
        }
        
    }
    
    public func logCompletedOnboarding() {
        
        if shouldLog {
            Analytics.logEvent("Onboarding_Completed", parameters: [:])
        }
        
    }
    
    public func logSelectedBranch(_ branch: String) {
        
        if shouldLog {
            Analytics.logEvent("Branch", parameters: ["name": branch])
        }
        
    }
    
    public func logSelectedItemContent(_ location: Location) {
        
        if shouldLog {
            Analytics.logEvent("Selected_Location_Drawer", parameters:
                ["location": location.category,
                 "name": location.name])
        }
        
    }
    
    public func logSelectedItem(_ location: Location) {
        
        if shouldLog {
            Analytics.logEvent("Selected_Location", parameters:
                ["location": location.category,
                 "name": location.name])
        }
        
    }
    
    public func logSelectedCluster(with memberCount: Int) {
        
        if shouldLog {
            Analytics.logEvent("Selected_Cluster", parameters:
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
            Analytics.logEvent("Opened_Pano", parameters: ["id": panoID])
        }
        
    }
    
    public func logUserType(_ type: User.UserType) {
        
        if shouldLog {
            Analytics.logEvent("Onboarding_User_Type", parameters: ["type": type.rawValue])
        }
        
    }
    
    public func logEnabledNotifications() {
        
        if shouldLog {
            Analytics.logEvent("Onboarding_Enabled_Notifications", parameters: [:])
        }
        
    }
    
    public func logEnabledLocation() {
        
        if shouldLog {
            Analytics.logEvent("Onboarding_Enabled_Notifications", parameters: [:])
        }
        
    }

    public func logPetrolType(_ type: FuelFeature.PetrolType) {
        
        if shouldLog {
            Analytics.logEvent("Onboarding_Petrol_Type", parameters: ["type": type.rawValue])
        }
        
    }
    
    public func logEnabledRubbishReminder(_ hour: Int) {
        
        if shouldLog {
            Analytics.logEvent("Onboarding_Enabled_Reminder", parameters: ["hour": hour])
        }
        
    }
    
}
