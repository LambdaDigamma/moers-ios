//
//  AppDelegate.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import UserNotifications
import Firebase
import Gestalt
import Haneke
import SwiftUI
import AppScaffold
import Resolver
import ModernNetworking
import RubbishFeature
import MMEvents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    
    var applicationController: ApplicationCoordinator!
    
    private let consumerKey = "7BHM9u39iH74aongQw0zN82wl"
    private let consumerSecret = "wJ1m2Prh2zsHJdcDyUnMkkZVQv07IIVPB3SuzAghiewcfQ888b"
    private let gcmMessageIDKey = "gcm.message_id"
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
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
        
        ThemeManager.default.theme = ApplicationTheme.dark
        ThemeManager.default.animated = true
        
        EventPackageConfiguration.accentColor = UIColor.systemYellow
        EventPackageConfiguration.onAccentColor = UIColor.black
        
//        MMUI.UIPackageConfiguration.accentColor = UIColor.systemYellow
//        MMUI.UIPackageConfiguration.onAccentColor = UIColor.black
        
        Core.UIPackageConfiguration.accentColor = UIColor.systemYellow
        Core.UIPackageConfiguration.onAccentColor = UIColor.black
        
        MMUIConfig.registerThemeManager(ThemeManager.default)
        MMAPIConfig.registerBaseURL(AppEnvironment.rootURL)
        MMAPIConfig.registerPetrolAPIKey("0dfdfad3-7385-ef47-2ff6-ec0477872677")
        MMAPIConfig.isMoersFestivalModeEnabled = false
        
        let configuration = NetworkingConfiguration()
        _ = configuration.setupEnvironmentAndLoader()
        let serviceConfiguration = ServiceConfiguration()
        
        serviceConfiguration.execute(with: application)
        
        UNUserNotificationCenter.current().delegate = self
        
        self.setupThirdParties()
        self.setup()
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    // MARK: - Scene Handling -
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - NSUserActivity
    
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        
        guard let tabBarController = window?.rootViewController as? AppTabBarController else {
            return false
        }
        
        if userActivity.activityType == "de.okfn.niederrhein.Moers.nextRubbish" {
            
            let rubbishService: RubbishService? = Resolver.optional()
            
            guard let rubbishService = rubbishService else {
                return false
            }
            
            if rubbishService.isEnabled && rubbishService.rubbishStreet != nil {
                tabBarController.selectedIndex = 0
                tabBarController.dashboard.pushRubbishViewController()
            }
            
        }
        
        return true
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
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
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        guard let fcmToken = fcmToken else {
            return
        }
        
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
//        TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
    }
    
}

extension AppDelegate {
    
    func resetIfNeeded() {
        
        guard CommandLine.arguments.contains("-reset") else {
            return
        }

        let defaultsName = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: defaultsName)
        UserDefaults.appGroup.removePersistentDomain(forName: defaultsName)

        Shared.dataCache.removeAll()
        Shared.JSONCache.removeAll()
        Shared.stringCache.removeAll()
        
    }
    
}
