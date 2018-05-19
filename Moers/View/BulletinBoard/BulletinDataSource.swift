//
//  BulletinDataSource.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BulletinBoard
import Gestalt

enum BulletinDataSource {
    
    // MARK: - Page
    
    static func makeIntroPage() -> PageBulletinItem {
        
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
        
        page.nextItem = makeNotitificationsPage()
        
        return page
        
    }
    
    static func makeNotitificationsPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("OnboardingNotificationPageTitle"))
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        page.imageAccessibilityLabel = "Notifications Icon"
        page.appearance = makeAppearance()
        page.descriptionText = String.localized("OnboardingNotificationPageDescription")
        page.actionButtonTitle = String.localized("OnboardingNotificationPageActionButtonTitle")
        page.alternativeButtonTitle = String.localized("OnboardingNotificationPageAlternativeButtonTitle")
        
        page.isDismissable = false
        
        page.actionHandler = { item in
            PermissionsManager.shared.requestRemoteNotifications()
            item.manager?.displayNextItem()
        }
        
        page.alternativeHandler = { item in
            item.manager?.displayNextItem()
        }
        
        page.nextItem = makeRubbishStreetPage()
        
        return page
        
    }
    
    static func makeCompletionPage() -> PageBulletinItem {
        
        let page = PageBulletinItem(title: String.localized("CompletionPageTitle"))
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
    
    static func makeRubbishStreetPage() -> PageBulletinItem {
        
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
            
            page.nextItem = makeRubbishReminderPage()
            
            item.manager?.displayNextItem()
            
        }
        
        page.alternativeHandler = { item in
            page.nextItem = makeCompletionPage()
            item.manager?.displayNextItem()
        }
        
        return page
        
    }
    
    static func makeRubbishReminderPage() -> PageBulletinItem {
        
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
        
        
        page.nextItem = makeCompletionPage()
        
        return page
        
    }
    
    static var userDidCompleteSetup: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserDidCompleteSetup")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserDidCompleteSetup")
        }
    }
    
}

extension BulletinDataSource {
    
    static func makeAppearance() -> BulletinAppearance {
        
        let appearance = BulletinAppearance()
        
        ThemeManager.default.apply(theme: Theme.self, to: appearance) { themeable, theme in
            
            themeable.titleTextColor = theme.color
            themeable.descriptionTextColor = theme.color
            themeable.actionButtonColor = theme.accentColor
            themeable.actionButtonTitleColor = theme.backgroundColor
            themeable.alternativeButtonColor = theme.color
            
        }
        
        return appearance
        
    }
    
}

// MARK: - Notifications

extension Notification.Name {
    
    static let SetupDidComplete = Notification.Name("SetupDidCompleteNotification")
    
}
