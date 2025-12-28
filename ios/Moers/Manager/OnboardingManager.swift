//
//  OnboardingManager.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import Core
import BLTNBoard
import CoreLocation
import Combine
import RubbishFeature
import FuelFeature
import Factory
import UIKit

// todo: Move Privacy Consent to Front of Onboarding
public class OnboardingManager {
    
    @LazyInjected(\.rubbishService) var rubbishService: RubbishService
    @LazyInjected(\.petrolService) var petrolService: PetrolService
    @LazyInjected(\.geocodingService) var geocodingService: GeocodingService
    @LazyInjected(\.locationService) var locationService: LocationService
    
    private let appearance: BLTNItemAppearance
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.appearance = OnboardingManager.makeAppearance()
    }
    
    func makeOnboarding() -> BLTNPageItem {
        
        let introPage = makeIntroPage()
        let privacyPage = makePrivacyPage()
        let userTypePage = makeUserTypePage(preSelected: nil)
        let notificationPage = makeNotitificationsPage()
        let locationPage = makeLocationPage()
        let petrolPage = makePetrolType(preSelected: nil)
        
//        introPage.next = userTypePage
//        userTypePage.next = notificationPage
//        notificationPage.next = locationPage
//        locationPage.next = privacyPage
//        privacyPage.next = petrolPage
        
        introPage.next = privacyPage
        privacyPage.next = userTypePage
        userTypePage.next = notificationPage
        notificationPage.next = locationPage
        locationPage.next = petrolPage
//        privacyPage.next = petrolPage
        
        return introPage
        
    }
    
    // MARK: - Pages
    
    func makeIntroPage() -> BLTNPageItem {
        
        let page = FeedbackPageBulletinItem(title: "Mein Moers")
        page.image = #imageLiteral(resourceName: "MoersAppIcon")
        page.imageAccessibilityLabel = "Mein Moers Logo"
        page.appearance = appearance
        page.descriptionText = String(localized: "Search shops & parking lots with live data and move through the city with interactive 360° panoramas! Find the cheapest petrol station or get reminders for rubbish collection.")
        page.actionButtonTitle = String(localized: "Continue")
        page.isDismissable = false
        
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        
        page.actionButtonAccessibilityIdentifier = "ContinueButton"
        page.titleLabelAccessibilityIdentifier = "StartAppTitleLabel"
        
        return page
        
    }
    
    func makeUserTypePage(preSelected: User.UserType?) -> BLTNPageItem {
        
        let page = SelectorBulletinPage<User.UserType>(title: String(localized: "User"), preSelected: preSelected)
        
        page.appearance = appearance
        page.descriptionText = String(localized: "Are you a visitor or citizen to the city of Moers?")
        page.actionButtonTitle = String(localized: "Continue")
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
        
        let page = FeedbackPageBulletinItem(title: String(localized: "Push Notifications"))
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        page.imageAccessibilityLabel = "Notifications Icon"
        page.descriptionText = String(localized: "Receive push notifications to keep up to date and be reminded of collection dates.")
        page.actionButtonTitle = String(localized: "Continue")
//        page.alternativeButtonTitle = String(localized: "Not now")
        page.appearance = appearance
        page.isDismissable = false
        
        page.actionHandler = { item in
            PermissionsManager.shared.requestRemoteNotifications()
            AnalyticsManager.shared.logEnabledNotifications()
            item.manager?.displayNextItem()
        }
        
//        page.alternativeHandler = { item in
//            item.manager?.displayNextItem()
//        }
        
        page.titleLabelAccessibilityIdentifier = "NotificationsTitleLabel"
        page.actionButtonAccessibilityIdentifier = "SubscribeNotificationsButton"
//        page.alternativeButtonAccessibilityIdentifier = "NotNowNotificationsButton"
        
        return page
        
    }
    
    func makeLocationPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String(localized: "Location"))
        
        page.image = #imageLiteral(resourceName: "LocationPrompt")
        page.imageAccessibilityLabel = "Location Icon"
        page.descriptionText = String(localized: "Mein Moers can use your location to find shops close to you and display nearby petrol prices.")
        page.actionButtonTitle = String(localized: "Continue")
//        page.alternativeButtonTitle = String.localized("Later")
        page.appearance = appearance
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            AnalyticsManager.shared.logEnabledLocation()
            
            self.locationService.authorizationStatus.sink { (authorizationStatus: CLAuthorizationStatus) in
                
                if authorizationStatus == .notDetermined {
                    self.locationService.requestWhenInUseAuthorization()
                    item.manager?.displayNextItem()
                } else {
                    item.manager?.displayNextItem()
                }

            }
            .store(in: &self.cancellables)
            
        }
        
//        page.alternativeHandler = { item in
//            item.manager?.displayNextItem()
//        }
        
        return page
        
    }
    
    func makePrivacyPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String(localized: "Privacy"))
        
        page.image = #imageLiteral(resourceName: "PrivacyPrompt")
        page.imageAccessibilityLabel = "Privacy Icon"
        page.descriptionText = String(localized: "All data will be treated with the utmost care and confidentiality! By using this app, you agree to the terms and conditions and privacy policy found in the menu.")
        page.actionButtonTitle = String(localized: "Understood")
        page.appearance = appearance
        page.isDismissable = false
        page.alternativeButtonTitle = String(localized: "Read")
        page.alternativeHandler = { _ in
            
            let url = URL(string: "https://next.moers.app/legal/privacy")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        
        page.actionHandler = { $0.manager?.displayNextItem() }
        
        return page
        
    }
    
    func makePetrolType(preSelected: FuelFeature.PetrolType?) -> BLTNPageItem {
        
        let page = SelectorBulletinPage<FuelFeature.PetrolType>(
            title: String(localized: "Petrol Type"),
            preSelected: preSelected
        )
        
        page.appearance = appearance
        page.descriptionText = String(localized: "Mein Moers can show you the current petrol prices. Select your preferred petrol type.")
        page.actionButtonTitle = String(localized: "Continue")
        page.isDismissable = false
        
        page.onSelect = { (type: FuelFeature.PetrolType) in
            self.petrolService.petrolType = type
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
        
        let page = RubbishStreetPickerItem(
            title: String(localized: "Pick-up Schedule")
        )
        
        page.appearance = appearance
        page.descriptionText = String(localized: "Mein Moers can show you the collection dates of the garbage collection and remind you to expose them.")
        page.image = #imageLiteral(resourceName: "yellowWaste")
        page.actionButtonTitle = String(localized: "Fortfahren")
        page.alternativeButtonTitle = String(localized: "Not now")
        
        page.isDismissable = false
        
        page.actionHandler = { [weak self] item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            self?.rubbishService.register(item.selectedStreet)
            self?.rubbishService.isEnabled = true
            
            page.next = self?.makeRubbishReminderPage()
            
            item.manager?.displayNextItem()
            
        }
        
        page.alternativeHandler = { [weak self] item in
            
            self?.rubbishService.remindersEnabled = false
            self?.rubbishService.disableReminder()
            
            page.next = self?.makeCompletionPage()
            item.manager?.displayNextItem()
            
        }
        
        return page
        
    }
    
    func makeRubbishReminderPage() -> BLTNPageItem {
        
        let page = RubbishReminderBulletinItem(title: String(localized: "Pick-up notifications"))
        page.descriptionText = String(localized: "Mein Moers can remind you to put your trash cans on the street in time.")
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        page.actionButtonTitle = String(localized: "Setup")
        page.alternativeButtonTitle = String(localized: "Not now")
        page.appearance = appearance
        page.isDismissable = false
        
        page.actionHandler = { [weak self] item in
            
            let hour = Calendar.current.component(.hour, from: page.picker.date)
            let minutes = Calendar.current.component(.minute, from: page.picker.date)
            
            if let rubbishService = self?.rubbishService {
                rubbishService.registerNotifications(at: hour, minute: minutes)
            }
            
            AnalyticsManager.shared.logEnabledRubbishReminder(hour)
            
            page.next = self?.makeCompletionPage()
            item.manager?.displayNextItem()
            
        }
        
        page.alternativeHandler = { item in
            page.next = self.makeCompletionPage()
            item.manager?.displayNextItem()
        }
        
        return page
        
    }
    
    func makeCompletionPage() -> BLTNPageItem {
        
        let page = FeedbackPageBulletinItem(title: String(localized: "Setup completed"))
        page.image = #imageLiteral(resourceName: "IntroCompletion")
        page.imageAccessibilityLabel = "Checkmark"
        page.appearance = appearance
        page.appearance.actionButtonColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        page.appearance.imageViewTintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        page.appearance.actionButtonTitleColor = .white
        page.alternativeButton?.isHidden = true
        
        page.descriptionText = ""
        page.actionButtonTitle = String(localized: "Get started")
        
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
            return UserDefaults.appGroup.bool(forKey: "UserDidCompleteSetup")
        }
        set {
            UserDefaults.appGroup.set(newValue, forKey: "UserDidCompleteSetup")
        }
    }
    
}

extension OnboardingManager {
    
    static func makeAppearance() -> BLTNItemAppearance {
        
        let appearance = BLTNItemAppearance()
        
        appearance.titleTextColor = UIColor.label
        appearance.descriptionTextColor = UIColor.label
        appearance.actionButtonColor = UIColor.systemYellow
        appearance.actionButtonTitleColor = UIColor.systemBackground
        appearance.alternativeButtonTitleColor = UIColor.label
        
        return appearance
        
    }
    
}
