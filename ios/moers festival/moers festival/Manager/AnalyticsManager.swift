//
//  AnalyticsManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import StoreKit
import MMEvents
import FirebaseAnalytics

class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private var isLoggingEnabled: Bool {
        return true
    }
    
    private let keyAppRuns = "kAppRuns"
    private let reviewRate = 5
    
    func incrementAppRuns() {
        
        let defaults = UserDefaults.standard
        
        let runs = getAppRuns() + 1
        
        defaults.set(runs, forKey: keyAppRuns)
        
    }
    
    func getAppRuns() -> Int {
        
        let defaults = UserDefaults.standard
        
        return defaults.integer(forKey: keyAppRuns)
        
    }
    
    public func showReview() {
        
        let runs = getAppRuns()
        
        if runs % reviewRate == 0 && runs >= 5 && !isSnapshotting() {
            if let scene = UIApplication.shared.currentScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        
    }
    
    public func logCompletedOnboarding() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Completed_Onboarding", parameters: nil)
        }
        
    }
    
    public func logOpenedStaffLogin() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Staff_Login_Opened", parameters: nil)
        }
        
    }
    
    public func logStaffLogin() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Staff_Login_Completed", parameters: nil)
        }
        
    }
    
    public func logSelectedSocialNews() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Social_News", parameters: nil)
        }
        
    }
    
    public func logSelectedOfficialNews() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Official_News", parameters: nil)
        }
        
    }
    
    public func logOpenTicket() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Opened_Ticket", parameters: nil)
        }
        
    }
    
    public func logSelectedTicket(_ ticketViewModel: TicketViewModel) {
        
        if isLoggingEnabled {
            Analytics.logEvent("Buy_Ticket", parameters: ["title": ticketViewModel.title])
        }
        
    }
    
    public func logOpenLodging() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Opened_Lodging", parameters: nil)
        }
        
    }
    
    public func logOpenAccessibility() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Opened_Accessibility", parameters: nil)
        }
        
    }
    
    public func logOpenAbout() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Opened_About", parameters: nil)
        }
        
    }
    
    public func logOpenPartner() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Opened_Partners", parameters: nil)
        }
        
    }
    
    public func logOpenEventsOverview() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Opened_Events Overview", parameters: nil)
        }
        
    }
    
    public func logOpenEventsFavourites() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Opened_Events_Favourites", parameters: nil)
        }
        
    }
    
    public func logOpenEventsList() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Opened_Events_List", parameters: nil)
        }
        
    }
    
    public func logOpenDetailEvent(_ event: Event) {
        
        if isLoggingEnabled {
            Analytics.logEvent(
                AnalyticsEventViewItem,
                parameters: [
                    AnalyticsParameterItemID: event.id,
                    AnalyticsParameterItemName: event.name
            ])
        }
        
    }
    
    public func logLikeEvent(_ event: Event) {
        
        if isLoggingEnabled {
            Analytics.logEvent("Liked_Event", parameters: ["title": event.name])
        }
        
    }
    
    public func logUnlikeEvent(_ event: Event) {
        
        if isLoggingEnabled {
            Analytics.logEvent("Unliked_Event", parameters: ["title": event.name])
        }
        
    }
    
    public func logEventSearch(text: String) {
        
        if isLoggingEnabled {
            Analytics.logEvent("Search_Event", parameters: ["query": text])
        }
        
    }
    
    public func logAllowedNotifications() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Allowed_Notifications", parameters: nil)
        }
        
    }
    
    public func logDeniedNotifications() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Denied_Notifications", parameters: nil)
        }
        
    }
    
    public func logDownloadMeinMoers() {
        
        if isLoggingEnabled {
            Analytics.logEvent("Download_Mein_Moers", parameters: nil)
        }
        
    }
    
    public func logCountdown() {
        if isLoggingEnabled {
            Analytics.logEvent("Livestream_Countdown", parameters: nil)
        }
    }
    
    public func logActiveStream() {
        if isLoggingEnabled {
            Analytics.logEvent("Livestream_ActiveStream", parameters: nil)
        }
    }
    
}
