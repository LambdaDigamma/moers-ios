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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let consumerKey = "7BHM9u39iH74aongQw0zN82wl"
    private let consumerSecret = "wJ1m2Prh2zsHJdcDyUnMkkZVQv07IIVPB3SuzAghiewcfQ888b"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self, Answers.self])
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.analyticsConfiguration.setAnalyticsCollectionEnabled(true)
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
        if StoreManager.firstLaunch {
            
            print("First launch")
            
            let plistPath = Bundle.main.path(forResource: "Settings", ofType: "plist")!
            
            let dic = NSMutableDictionary()
            
            dic.addEntries(from: ["branches": Dictionary<String, Bool>()])
            
            print(dic)
            
            dic.write(to: URL(fileURLWithPath: plistPath), atomically: false)
            
            StoreManager.firstLaunch = false
            
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let applicationController = ApplicationController()
        
        window!.rootViewController = applicationController
        window!.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

struct StoreManager {
    static var firstLaunch: Bool {
        get { return !UserDefaults.standard.bool(forKey: "firstLaunch") }
        set { UserDefaults.standard.set(newValue, forKey: "firstLaunch") }
    }
}
