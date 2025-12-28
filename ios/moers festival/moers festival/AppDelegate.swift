//
//  AppDelegate.swift
//  moers festival
//
//  Created by Lennart Fischer on 28.01.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import Resolver
import UserNotifications
import AppScaffold
import FirebaseMessaging
import FirebaseCore
import MMEvents
import Combine
import OSLog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let bootstrappingProcedure: BootstrappingProcedure = [
            LaunchArgumentsHandler(),
            NetworkingConfiguration(),
            MMAPIFrameworkConfiguration(),
            MMEventsFrameworkConfiguration(),
            MMFeedsFrameworkConfiguration(),
            MMPagesFrameworkConfiguration(),
            ServiceConfiguration(),
            TwitterFramework(),
            FirebaseFrameworkConfiguration(),
            ShortcutConfiguration(),
            MediaLibraryConfiguration()
        ]
        
        bootstrappingProcedure.execute(with: application)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - UIApplication Lifecycle
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        ConfigManager.shared.fetchConfig()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    // MARK: - Notifications -
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        Logger(.default).info("Received notification \(userInfo)")
        
        
        
        if let refreshContent = userInfo["refresh_content"] as? String {
            
            Logger(.default).info("Received refresh content notification \(refreshContent)")
            
            switch refreshContent {
                case "events":
                    return refreshEvents(completionHandler: completionHandler)
                case "maps":
                    return refreshMap(completionHandler: completionHandler)
                default:
                    break
            }
            
        }
        
        completionHandler(.noData)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error registering remote notifications with error: \(error)")
    }
    
    // MARK: - Refresh Content -
    
    private func refreshEvents(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let eventService: LegacyEventService = Resolver.optional() else { return }
        
        eventService.invalidateCache()
        
        NotificationCenter.default.post(name: NSNotification.Name.updatedEvents, object: nil)
        
        completionHandler(.newData)
        
    }
    
    private func refreshMap(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let service: LocationEventService = Resolver.resolve()
        
        Task {
            await service.updateLocalFestivalArchive(force: true)
            completionHandler(.newData)
        }
        
    }
    
}
