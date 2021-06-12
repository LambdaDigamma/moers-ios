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
import Gestalt
import MMAPI
import MMUI
import MMCommon
import Haneke
import SwiftUI
import AppScaffold
import Resolver
import ModernNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    
    private let consumerKey = "7BHM9u39iH74aongQw0zN82wl"
    private let consumerSecret = "wJ1m2Prh2zsHJdcDyUnMkkZVQv07IIVPB3SuzAghiewcfQ888b"
    private let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        LaunchArgumentsHandler(userDefaults: UserDefaults.standard).handle()
        #endif
        
        self.resetIfNeeded()
        
//        let bootstrappingProcedure: BootstrappingProcedure = [
//            LaunchArgumentsHandler(),
//            NetworkingConfiguration(),
//        ]
//
//        bootstrappingProcedure.execute(with: application)
        
        ThemeManager.default.theme = UserManager.shared.theme
        ThemeManager.default.animated = true
        
        MMUIConfig.registerThemeManager(ThemeManager.default)
        MMAPIConfig.registerBaseURL(Environment.rootURL)
        MMAPIConfig.registerPetrolAPIKey("0dfdfad3-7385-ef47-2ff6-ec0477872677")
        MMAPIConfig.isMoersFestivalModeEnabled = false
        
        RubbishManager.shared.rubbishStreetURL = URL(string: "https://moers.app/abfallkalender-strassenverzeichnis-2020-01.csv")
        RubbishManager.shared.rubbishDateURL = URL(string: "https://moers.app/abfallkalender-termine-2020-01.csv")
        
        
        
        let sessionConfig = URLSessionConfiguration.default
//        let apiKey = "ey...."
//        sessionConfig.httpAdditionalHeaders = [
//            "Authorization": "Bearer \(apiKey)"
//        ]
        
        let config = MMAPIConfig(baseURL: URL(string: Environment.baseURL)!)
//        let client = APIClient(config: config, urlSessionConfiguration: sessionConfig, adapters: [LoggingAdapter()])
        
        let configuration = NetworkingConfiguration()
        let loader = configuration.setupEnvironmentAndLoader()
        
        let applicationController = ApplicationController(loader: loader)
        
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
    
    // MARK: - NSUserActivity
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let viewController = window?.rootViewController as! TabBarController
        
        if userActivity.activityType == "de.okfn.niederrhein.Moers.nextRubbish" {
            
            if RubbishManager.shared.isEnabled && RubbishManager.shared.rubbishStreet != nil {
                
                viewController.selectedIndex = 0
                viewController.dashboard.pushRubbishViewController()
                
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

    // MARK: - Notifications
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
        
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
        
        let data: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: data)
        
    }
    
    // MARK: - Helper
    
    private func setup() {
        AnalyticsManager.shared.numberOfAppRuns += 1
    }
    
    private func setupThirdParties() {
        
        FirebaseConfiguration.shared.setLoggerLevel(.warning)
        Analytics.setAnalyticsCollectionEnabled(true)
        FirebaseApp.configure()
        
        
        Messaging.messaging().delegate = self
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
    }
    
}

extension AppDelegate {
    
    func resetIfNeeded() {
        
        guard CommandLine.arguments.contains("-reset") else {
            return
        }

        let defaultsName = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: defaultsName)

        Shared.dataCache.removeAll()
        Shared.JSONCache.removeAll()
        Shared.stringCache.removeAll()
        
    }
    
}
