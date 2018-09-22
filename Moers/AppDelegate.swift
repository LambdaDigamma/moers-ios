//
//  AppDelegate.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import Crashlytics
import TwitterKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    private let consumerKey = "7BHM9u39iH74aongQw0zN82wl"
    private let consumerSecret = "wJ1m2Prh2zsHJdcDyUnMkkZVQv07IIVPB3SuzAghiewcfQ888b"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupThirdParties()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let applicationController = ApplicationController()
        
        window!.rootViewController = applicationController
        window!.makeKeyAndVisible()
        
        AnalyticsManager.shared.numberOfAppRuns += 1
        
        application.applicationIconBadgeNumber = 0
        
        OperationQueue.main.addOperation {
            UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
        }
        
        return true
    }
    
    private func setupThirdParties() {
        
        Fabric.with([Crashlytics.self, Answers.self])
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.analyticsConfiguration.setAnalyticsCollectionEnabled(true)
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
        
    }
    
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

}
