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
    private let kPetrolPrices = "petrol"
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
    
}
