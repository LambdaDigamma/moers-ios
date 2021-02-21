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
import CoreLocation
import MMAPI
import MMUI
import ReactiveKit

// TODO: Move Privacy Consent to Front of Onboarding
class OnboardingManager {
    
    private let locationManager: LocationManagerProtocol
    private let geocodingManager: GeocodingManagerProtocol
    private let rubbishManager: RubbishManagerProtocol
    private var petrolManager: PetrolManagerProtocol
    private let appearance: BLTNItemAppearance
    private let bag: DisposeBag
    
    init(locationManager: LocationManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         rubbishManager: RubbishManagerProtocol,
         petrolManager: PetrolManagerProtocol) {
        
        self.locationManager = locationManager
        self.geocodingManager = geocodingManager
        self.rubbishManager = rubbishManager
        self.petrolManager = petrolManager
        self.appearance = OnboardingManager.makeAppearance()
        self.bag = DisposeBag()
        
    }
    
    func makeOnboarding() -> BLTNPageItem {
        
        let introPage = makeIntroPage()
        let userTypePage = makeUserTypePage(preSelected: nil)
        let notificationPage = makeNotitificationsPage()
        let locationPage = makeLocationPage()
        let privacyPage = makePrivacyPage()
        let petrolPage = makePetrolType(preSelected: nil)
        
        introPage.next = userTypePage
        userTypePage.next = notificationPage
        notificationPage.next = locationPage
        locationPage.next = privacyPage
        privacyPage.next = petrolPage
        
        return introPage
        
    }
    
    // MARK: - Pages
    
    func makeIntroPage() -> BLTNPageItem {
        
        let page = FeedbackPageBulletinItem(title: "Mein Moers")
        page.image = #imageLiteral(resourceName: "MoersAppIcon")
        page.imageAccessibilityLabel = "Mein Moers Logo"
        page.appearance = appearance
        page.descriptionText = String.localized("OnboardingDescription")
        page.actionButtonTitle = String.localized("OnboardingFirstPageActionButtonTitle")
        page.isDismissable = false
        
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        
        page.actionButtonAccessibilityIdentifier = "ContinueButton"
        page.titleLabelAccessibilityIdentifier = "StartAppTitleLabel"
        
        return page
        
    }
    
    func makeUserTypePage(preSelected: User.UserType?) -> BLTNPageItem {
        
        let page = SelectorBulletinPage<User.UserType>(title: String.localized("OnboardingUserTypeSelectorPageTitle"), preSelected: preSelected)
        
        page.appearance = appearance
        page.descriptionText = String.localized("OnboardingUserTypeSelectorPageDescription")
        page.actionButtonTitle = String.localized("OnboardingUserTypeSelectorPageActionButtonTitle")
        page.isDismissable = false
        page.onSelect = { type in
            
            let user = User(type: type, id: nil, name: nil, description: nil)
            
            UserManager.shared.register(user)
            
            AnalyticsManager.shared.logUserType(type)
            
        }
        
        page.actionHandler = { $0.manager?.displayNextItem() }
        
        page.actionButtonAccessibilityIdentifier = "ContinueButton"
        page.titleLabelAccessibilityIdentifier = "CitizenTypeTitleLabel"
        
        return page
        
    }
    
    func makeNotitificationsPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("OnboardingNotificationPageTitle"))
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        page.imageAccessibilityLabel = "Notifications Icon"
        page.descriptionText = String.localized("OnboardingNotificationPageDescription")
        page.actionButtonTitle = String.localized("OnboardingNotificationPageActionButtonTitle")
        page.alternativeButtonTitle = String.localized("OnboardingNotificationPageAlternativeButtonTitle")
        page.appearance = appearance
        page.isDismissable = false
        
        page.actionHandler = { item in
            PermissionsManager.shared.requestRemoteNotifications()
            AnalyticsManager.shared.logEnabledNotifications()
            item.manager?.displayNextItem()
        }
        
        page.alternativeHandler = { item in
            item.manager?.displayNextItem()
        }
        
        page.titleLabelAccessibilityIdentifier = "NotificationsTitleLabel"
        page.actionButtonAccessibilityIdentifier = "SubscribeNotificationsButton"
        page.alternativeButtonAccessibilityIdentifier = "NotNowNotificationsButton"
        
        return page
        
    }
    
    func makeLocationPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("OnboardingLocationPageTitle"))
        
        page.image = #imageLiteral(resourceName: "LocationPrompt")
        page.imageAccessibilityLabel = "Location Icon"
        page.descriptionText = String.localized("OnboardingLocationPageDescription")
        page.actionButtonTitle = String.localized("Allow")
        page.alternativeButtonTitle = String.localized("Later")
        page.appearance = appearance
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            AnalyticsManager.shared.logEnabledLocation()
            
            self.locationManager.authorizationStatus.observeNext(with: { authorizationStatus in
                
                if authorizationStatus == .notDetermined {
                    self.locationManager.requestWhenInUseAuthorization()
                } else {
                    item.manager?.displayNextItem()
                }
                
            }).dispose(in: self.bag)
            
        }
        
        page.alternativeHandler = { item in
            item.manager?.displayNextItem()
        }
        
        return page
        
    }
    
    func makePrivacyPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("PrivacyPageTitle"))
        
        page.image = #imageLiteral(resourceName: "PrivacyPrompt")
        page.imageAccessibilityLabel = "Privacy Icon"
        page.descriptionText = String.localized("PrivacyPageDescription")
        page.actionButtonTitle = String.localized("PrivacyPageButtonTitle")
        page.appearance = appearance
        page.isDismissable = false
        
        page.actionHandler = { $0.manager?.displayNextItem() }
        
        return page
        
    }
    
    func makePetrolType(preSelected: PetrolType?) -> BLTNPageItem {
        
        let page = SelectorBulletinPage<PetrolType>(
            title: String.localized("OnboardingPetrolTypePageTitle"),
            preSelected: preSelected
        )
        
        page.appearance = appearance
        page.descriptionText = String.localized("OnboardingPetrolTypePageDescription")
        page.actionButtonTitle = String.localized("OnboardingPetrolTypePageActionButtonTitle")
        page.isDismissable = false
        
        page.onSelect = { type in
            self.petrolManager.petrolType = type
            AnalyticsManager.shared.logPetrolType(type)
        }
        
        page.actionHandler = {
            
            if UserManager.shared.user.type == .citizen {
                page.next = self.makeRubbishStreetPage()
            } else {
                page.next = self.makeCompletionPage()
            }
            
            $0.manager?.displayNextItem()
            
        }
        
        return page
        
    }
    
    func makeRubbishStreetPage() -> BLTNPageItem {
        
        let page = RubbishStreetPickerItem(title: String.localized("RubbishCollectionPageTitle"),
                                           locationManager: locationManager,
                                           geocodingManager: geocodingManager,
                                           rubbishManager: rubbishManager)
        
        page.appearance = appearance
        page.descriptionText = String.localized("RubbishCollectionPageDescription")
        page.image = #imageLiteral(resourceName: "yellowWaste")
        page.actionButtonTitle = String.localized("RubbishCollectionPageActionButtonTitle")
        page.alternativeButtonTitle = String.localized("RubbishCollectionPageAlternativeButtonTitle")
        
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            RubbishManager.shared.register(item.selectedStreet)
            RubbishManager.shared.isEnabled = true
            
            page.next = self.makeRubbishReminderPage()
            
            item.manager?.displayNextItem()
            
        }
        
        page.alternativeHandler = { item in
            
            RubbishManager.shared.remindersEnabled = false
            RubbishManager.shared.disableReminder()
            
            page.next = self.makeCompletionPage()
            item.manager?.displayNextItem()
        }
        
        return page
        
    }
    
    func makeRubbishReminderPage() -> BLTNPageItem {
        
        let page = RubbishReminderBulletinItem(title: String.localized("RubbishCollectionReminderPageTitle"))
        page.descriptionText = String.localized("RubbishCollectionReminderPageDescription")
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        page.actionButtonTitle = String.localized("RubbishCollectionReminderPageActionButtonTitle")
        page.alternativeButtonTitle = String.localized("RubbishCollectionReminderPageAlternativeButtonTitle")
        page.appearance = appearance
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            let hour = Calendar.current.component(.hour, from: page.picker.date)
            let minutes = Calendar.current.component(.minute, from: page.picker.date)
            
            RubbishManager.shared.registerNotifications(at: hour, minute: minutes)
            AnalyticsManager.shared.logEnabledRubbishReminder(hour)
            
            page.next = self.makeCompletionPage()
            item.manager?.displayNextItem()
            
        }
        
        page.alternativeHandler = { item in
            page.next = self.makeCompletionPage()
            item.manager?.displayNextItem()
        }
        
        return page
        
    }
    
    func makeCompletionPage() -> BLTNPageItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("CompletionPageTitle"))
        page.image = #imageLiteral(resourceName: "IntroCompletion")
        page.imageAccessibilityLabel = "Checkmark"
        page.appearance = appearance
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
            
            let successFeedback = SuccessFeedbackGenerator()
            
            successFeedback.prepare()
            successFeedback.success()
            
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
    
    static func makeAppearance() -> BLTNItemAppearance {
        
        let appearance = BLTNItemAppearance()
        
        MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: appearance)
        
        return appearance
        
    }
    
}

// MARK: - Notifications

extension Notification.Name {
    
    static let SetupDidComplete = Notification.Name("SetupDidCompleteNotification")
    
}

extension BLTNItemAppearance: Themeable {
    
    public typealias Theme = ApplicationTheme
    
    public func apply(theme: Theme) {
        
        self.titleTextColor = theme.color
        self.descriptionTextColor = theme.color
        self.actionButtonColor = theme.accentColor
        self.actionButtonTitleColor = theme.backgroundColor
        self.alternativeButtonTitleColor = theme.color
        
    }
    
}
