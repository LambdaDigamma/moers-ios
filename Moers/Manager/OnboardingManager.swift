//
//  OnboardingManager.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import BLTNBoard
import Gestalt

struct OnboardingManager {
    
    static var shared = OnboardingManager()
    
    // MARK: - Pages
    
    func makeIntroPage() -> BLTNPageItem {
        
        let page = FeedbackPageBulletinItem(title: "Mein \(AppConfig.shared.name)")
        page.image = #imageLiteral(resourceName: "MoersAppIcon")
        page.imageAccessibilityLabel = "Mein Moers Logo"
        page.appearance = makeAppearance()
        page.descriptionText = String.localized("OnboardingDescription")
        page.actionButtonTitle = String.localized("OnboardingFirstPageActionButtonTitle")
        page.isDismissable = false
        
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        
        page.next = makeUserTypePage()
        
        return page
        
    }
    
    func makeUserTypePage() -> BLTNPageItem {
        
        
        let page = UserTypeSelectorBulletinPage(title: String.localized("OnboardingUserTypeSelectorPageTitle"))
        
        page.appearance = makeAppearance()
        page.descriptionText = String.localized("OnboardingUserTypeSelectorPageDescription")
        page.actionButtonTitle = String.localized("OnboardingUserTypeSelectorPageActionButtonTitle")
        page.isDismissable = false
        
        page.next = makeNotitificationsPage()
        
        return page
        
    }
    
    func makeNotitificationsPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("OnboardingNotificationPageTitle"))
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        page.imageAccessibilityLabel = "Notifications Icon"
        page.descriptionText = String.localized("OnboardingNotificationPageDescription")
        page.actionButtonTitle = String.localized("OnboardingNotificationPageActionButtonTitle")
        page.alternativeButtonTitle = String.localized("OnboardingNotificationPageAlternativeButtonTitle")
        page.appearance = makeAppearance()
        page.isDismissable = false
        
        page.actionHandler = { item in
            PermissionsManager.shared.requestRemoteNotifications()
            item.manager?.displayNextItem()
        }
        
        page.alternativeHandler = { item in
            item.manager?.displayNextItem()
        }
        
        page.next = makeLocationPage()
        
        return page
        
    }
    
    func makeLocationPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("OnboardingLocationPageTitle"))
        
        page.image = #imageLiteral(resourceName: "LocationPrompt")
        page.imageAccessibilityLabel = "Location Icon"
        page.descriptionText = String.localized("OnboardingNotificationPageDescription")
        page.actionButtonTitle = String.localized("Allow")
        page.alternativeButtonTitle = String.localized("Later")
        page.appearance = makeAppearance()
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            LocationManager.shared.requestWhenInUseAuthorization(completion: {
                
                if UserManager.shared.user.type == .citizen {
                    page.next = self.makeRubbishStreetPage()
                } else {
                    page.next = self.makeCompletionPage()
                }
                
                item.manager?.displayNextItem()
                
            })
            
        }
        
        page.alternativeHandler = { item in
            
            page.next = self.makeCompletionPage()
            
            item.manager?.displayNextItem()
            
        }
        
        return page
        
    }
    
    func makeRubbishStreetPage() -> BLTNPageItem {
        
        let page = RubbishStreetPickerItem(title: String.localized("RubbishCollectionPageTitle"))
        page.appearance = makeAppearance()
        page.descriptionText = String.localized("RubbishCollectionPageDescription")
        page.image = #imageLiteral(resourceName: "yellowWaste")
        page.actionButtonTitle = String.localized("RubbishCollectionPageActionButtonTitle")
        page.alternativeButtonTitle = String.localized("RubbishCollectionPageAlternativeButtonTitle")
        
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            let selectedStreet = item.streets[item.picker.currentSelectedRow]
            
            RubbishManager.shared.register(selectedStreet)
            
            page.next = self.makeRubbishReminderPage()
            
            item.manager?.displayNextItem()
            
        }
        
        page.alternativeHandler = { item in
            
            RubbishManager.shared.remindersEnabled = false
            RubbishManager.shared.reminderHour = 20
            RubbishManager.shared.reminderMinute = 0
            
            page.next = self.makeCompletionPage()
            item.manager?.displayNextItem()
        }
        
        return page
        
    }
    
    func makeRubbishReminderPage() -> BLTNPageItem {
        
        let page = RubbishReminderBulletinItem(title: String.localized("RubbishCollectionReminderPageTitle"))
        page.appearance = makeAppearance()
        page.descriptionText = String.localized("RubbishCollectionReminderPageDescription")
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        page.actionButtonTitle = String.localized("RubbishCollectionReminderPageActionButtonTitle")
        page.alternativeButtonTitle = String.localized("RubbishCollectionReminderPageAlternativeButtonTitle")
        
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            let hour = Calendar.current.component(.hour, from: page.picker.date)
            let minutes = Calendar.current.component(.minute, from: page.picker.date)
            
            RubbishManager.shared.registerNotifications(at: hour, minute: minutes)
            
            item.manager?.displayNextItem()
            
        }
        
        page.alternativeHandler = { item in
            item.manager?.displayNextItem()
        }
        
        
        page.next = makeCompletionPage()
        
        return page
        
    }
    
    func makeCompletionPage() -> BLTNPageItem {
        
        let page = BLTNPageItem(title: String.localized("CompletionPageTitle"))
        page.image = #imageLiteral(resourceName: "IntroCompletion")
        page.imageAccessibilityLabel = "Checkmark"
        page.appearance = makeAppearance()
        page.appearance.actionButtonColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        page.appearance.imageViewTintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        page.appearance.actionButtonTitleColor = .white
        page.alternativeButton?.isHidden = true
        
        page.descriptionText = ""
        page.actionButtonTitle = String.localized("CompletionPageActionButtonTitle")
        
        page.isDismissable = true
        
        page.dismissalHandler = { item in
            NotificationCenter.default.post(name: .SetupDidComplete, object: item)
        }
        
        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
        
    }
    
    var userDidCompleteSetup: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserDidCompleteSetup")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserDidCompleteSetup")
        }
    }
    
}

extension OnboardingManager {
    
    func makeAppearance() -> BLTNItemAppearance {
        
        let appearance = BLTNItemAppearance()
        
        ThemeManager.default.apply(theme: Theme.self, to: appearance) { themeable, theme in
            
            themeable.titleTextColor = theme.color
            themeable.descriptionTextColor = theme.color
            themeable.actionButtonColor = theme.accentColor
            themeable.actionButtonTitleColor = theme.backgroundColor
            themeable.alternativeButtonTitleColor = theme.color
            
        }
        
        return appearance
        
    }
    
}

// MARK: - Notifications

extension Notification.Name {
    
    static let SetupDidComplete = Notification.Name("SetupDidCompleteNotification")
    
}
