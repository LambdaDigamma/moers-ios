//
//  BulletinDataSource.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import BLTNBoard
import CoreLocation

enum BulletinDataSource {
    
    // MARK: - Page
    
    static func makeIntroPage() -> BLTNPageItem {
        
        let page = FeedbackPageBulletinItem(title: "moers festival")
        page.image = #imageLiteral(resourceName: "Icon")
        page.imageAccessibilityLabel = "Moers Festival Logo"
        page.appearance = makeAppearance()
        page.descriptionText = String.localized("Discover the moers festival")
        page.actionButtonTitle = String.localized("Continue")
        page.isDismissable = false
                
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        
        page.next = makeNotitificationsPage()
        
        return page
        
    }
    
    static func makeNotitificationsPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("Push Notifications"))
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        page.imageAccessibilityLabel = "Notifications Icon"
        page.appearance = makeAppearance()
        page.descriptionText = String.localized("Receive push notifications to get all the latest news about Moers Festival.")
        page.actionButtonTitle = String.localized("Subscribe")
        page.alternativeButtonTitle = String.localized("Not now")
        
        page.isDismissable = false
        
        page.actionHandler = { item in
            PermissionsManager.shared.requestRemoteNotifications()
            AnalyticsManager.shared.logAllowedNotifications()
            item.manager?.displayNextItem()
        }

        page.alternativeHandler = { item in
            AnalyticsManager.shared.logDeniedNotifications()
            item.manager?.displayNextItem()
        }

        page.next = makeLocationPage()
        
        return page
        
    }
    
    static func makeLocationPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("Location"))
        
        page.image = #imageLiteral(resourceName: "LocationPrompt")
        page.imageAccessibilityLabel = "Location Icon"
        page.descriptionText = String.localized("Moers Festival uses your location to provide you with more detailed information about the sites and moving stages.")
        page.actionButtonTitle = String.localized("Continue")
//        page.alternativeButtonTitle = String.localized("Later")
        page.appearance = makeAppearance()
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            if LocationManager.shared.authorizationStatus == CLAuthorizationStatus.notDetermined {
                
                LocationManager.shared.requestWhenInUseAuthorization(completion: {
                    
                    item.manager?.displayNextItem()
                    
                })
                
            } else {
                item.manager?.displayNextItem()
            }
            
        }
        
//        page.alternativeHandler = { item in
//            
//            item.manager?.displayNextItem()
//            
//        }
        
        page.next = makePrivacyPage()
        
        return page
        
    }
    
    static func makePrivacyPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("Privacy"))
        
        page.image = #imageLiteral(resourceName: "PrivacyPrompt")
        page.imageAccessibilityLabel = "Privacy Icon"
        page.descriptionText = String.localized("All data will be treated with the utmost care and confidentiality! \nBy using this app, you agree to the terms and conditions and privacy policy found in the menu.")
        page.actionButtonTitle = String.localized("Understood")
        page.appearance = makeAppearance()
        page.isDismissable = false
        
        page.actionHandler = { $0.manager?.displayNextItem() }
        
        page.next = makeMoersAppPage()
        
        return page
        
    }
    
    static func makeMoersAppPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: String.localized("Mein Moers"))
        page.image = #imageLiteral(resourceName: "MoersAppIcon")
        page.imageAccessibilityLabel = "Moers App Icon Icon"
        page.appearance = makeAppearance()
        page.descriptionText = String.localized("Mein Moers is a nice addition to this app. \nExplore the city with 360° panoramas, find shops and get current parking allocation data.")
        page.actionButtonTitle = String.localized("Download")
        page.alternativeButtonTitle = String.localized("Later")
        
        page.isDismissable = false
        
        page.actionHandler = { item in
            
            AnalyticsManager.shared.logDownloadMeinMoers()
            
            UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/bars/id1305862555")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (_) in
                item.manager?.displayNextItem()
            })
            
        }
        
        page.alternativeHandler = { item in
            item.manager?.displayNextItem()
        }
        
        page.next = makeCompletionPage()
        
        return page
        
    }
    
    static func makeCompletionPage() -> BLTNPageItem {
        
        let page = BLTNPageItem(title: String.localized("Setup completed"))
        page.image = #imageLiteral(resourceName: "IntroCompletion")
        page.imageAccessibilityLabel = "Checkmark"
        page.appearance = makeAppearance()
        page.appearance.actionButtonColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        page.appearance.imageViewTintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        page.appearance.actionButtonTitleColor = .white
        page.alternativeButton?.isHidden = true
        
        page.descriptionText = ""
        page.actionButtonTitle = String.localized("Get started")
        
        page.isDismissable = true
        
        page.dismissalHandler = { item in
            NotificationCenter.default.post(name: .SetupDidComplete, object: item)
        }
        
        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
        
    }
    
    static func makeErrorPage(with title: String) -> BLTNPageItem {
        
        let page = BLTNPageItem(title: title)
        page.image = #imageLiteral(resourceName: "error").withRenderingMode(.alwaysTemplate)
        page.imageAccessibilityLabel = "Error"
        page.appearance = makeAppearance()
        page.appearance.actionButtonColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        page.appearance.imageViewTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        page.appearance.actionButtonTitleColor = .white
        page.alternativeButton?.isHidden = true
        
        page.descriptionText = ""
        page.actionButtonTitle = String.localized("Okay")
        
        page.isDismissable = true
        
        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
        
    }
    
    static func makeStaffLoginPage(completion: @escaping ((Bool) -> ())) -> StaffLoginBulletinPage {
        
        let page = StaffLoginBulletinPage(title: String.localized("Staff Login"))
        page.appearance = makeAppearance()
        page.actionButtonTitle = String.localized("Login")
        page.isDismissable = true
        
        page.textInputHandler = { (item, text) in
            
            guard let password = text else { return }
            
            let success = AdminManager.shared.login(with: password)
            
            if success {
                
                AnalyticsManager.shared.logStaffLogin()
                
                page.next = makeCompletionPage()
                page.manager?.displayNextItem()
                completion(true)
                
            } else {
                
                page.next = makeErrorPage(with: "Login failed")
                page.manager?.displayNextItem()
                completion(false)
                
            }
            
        }
        
        return page
        
    }
    
    static func makeMutedPage() -> BLTNPageItem {
        
        let page = BLTNPageItem(title: "")
        page.image = UIImage(systemName: "speaker.slash.fill")!.withRenderingMode(.alwaysTemplate)
        page.imageAccessibilityLabel = "Muted"
        page.appearance = makeAppearance()
        page.appearance.actionButtonColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        page.appearance.imageViewTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        page.appearance.actionButtonTitleColor = .white
        page.alternativeButton?.isHidden = true
        
        page.descriptionText = String.localized("You have been muted by the operator and can no longer ask questions.")
        page.actionButtonTitle = String.localized("Okay")
        
        page.isDismissable = true
        
        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
        
    }
    
    static func makeNotificationBuilderPage() -> FeedbackPageBulletinItem {
        
        let page = NotificationBuilderBulletinPage(title: String.localized("Push Notification"))
        page.appearance = makeAppearance()
        page.actionButtonTitle = String.localized("Send")
        page.alternativeButtonTitle = String.localized("Cancel")
        page.isDismissable = true
        
        page.alternativeHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        page.actionHandler = { item in
            
            if let p = item as? NotificationBuilderBulletinPage {
                
                if p.titleTextField.text != "" {
                    
                    AdminManager.shared.sendPushMessage(title: p.titleTextField.text ?? "", text: p.bodyTextField.text ?? "")
                    
                    page.manager?.dismissBulletin(animated: true)
                    
                }
                
            }
            
        }
        
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
    
    static func makeAppearance() -> BLTNItemAppearance {
        
        let appearance = BLTNItemAppearance()
        
        appearance.titleTextColor = UIColor.label
        appearance.descriptionTextColor = UIColor.label
        appearance.actionButtonColor = AppColors.navigationAccent
        appearance.actionButtonTitleColor = AppColors.onAccent
        appearance.alternativeButtonTitleColor = UIColor.label
        
        return appearance
        
    }
    
}

// MARK: - Notifications

extension Notification.Name {
    
    static let SetupDidComplete = Notification.Name("SetupDidCompleteNotification")
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
