//
//  AppDelegate.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import TwitterKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    
    private let consumerKey = "7BHM9u39iH74aongQw0zN82wl"
    private let consumerSecret = "wJ1m2Prh2zsHJdcDyUnMkkZVQv07IIVPB3SuzAghiewcfQ888b"
    private let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let applicationController = ApplicationController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = applicationController
        window!.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().delegate = self
        
        self.setupThirdParties()
        self.setup()
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
        
        
        return true
    }
    
    // MARK: - Notifications

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
        
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
    }
    
    // MARK: - NSUserActivity
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let viewController = window?.rootViewController as! TabBarController
        
        if userActivity.activityType == "de.okfn.niederrhein.Moers.nextRubbish" {
            
            if RubbishManager.shared.isEnabled && RubbishManager.shared.rubbishStreet != nil {
                
                viewController.selectedIndex = 0
                viewController.dashboardViewController.openRubbishViewController()
                
            }
            
        }
        
        return true
        
    }
    
    // MARK: - UIApplication Lifecycle
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }

    // MARK: - Helper
    
    private func setup() {
        
        AnalyticsManager.shared.numberOfAppRuns += 1
        
        OperationQueue.main.addOperation {
            UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
        }
        
    }
    
    private func setupThirdParties() {
        
        Fabric.with([Crashlytics.self, Answers.self])
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.analyticsConfiguration.setAnalyticsCollectionEnabled(true)
        
        Messaging.messaging().delegate = self
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
    }
    
}
