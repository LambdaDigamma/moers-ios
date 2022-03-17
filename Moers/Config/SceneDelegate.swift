//
//  SceneDelegate.swift
//  Moers
//
//  Created by Lennart Fischer on 06.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit
import OSLog
import RubbishFeature
import Core

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private let logger = Logger(.default)
    
    public var window: UIWindow?
    public var applicationCoordinator: ApplicationCoordinator!
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        
        self.applicationCoordinator = ApplicationCoordinator()

        window!.overrideUserInterfaceStyle = .dark
        window!.rootViewController = applicationCoordinator.rootViewController()
        window!.makeKeyAndVisible()
        
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                applicationCoordinator.handleUniversalLinks(from: userActivity)
            }
            
            logger.info("Configuring user activity")
//            if !configure(window: window, with: userActivity) {
//                Swift.debugPrint("Failed to restore from \(userActivity)")
//            }
        }
        
//        if let restorationActivity = session.stateRestorationActivity {
//            self.configure(window: window, with: restorationActivity)
//        }
        
    }
    
    // MARK: - State Restoration
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
    
    // MARK: - Handle Universal Links -
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        logger.info("Continueing user activity of type \(userActivity.activityType)")
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("Coming from webbrowsing")
            applicationCoordinator.handleUniversalLinks(from: userActivity)
        }
        
        if userActivity.activityType == UserActivities.IDs.rubbishSchedule
            || userActivity.activityType == WidgetKinds.rubbish.rawValue {
            applicationCoordinator.openRubbishScheduleDetails()
        }
        
        print(userActivity.activityType)
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        logger.info("Received \(URLContexts.count) URLContexts")
        
        if let link = URLContexts.first?.url {
            logger.info("Opening a news article from widget")
            applicationCoordinator.openNewsArticle(url: link)
        }
        
    }
    
}

public extension Collection where Element == String {
    
    func containsPathElement(_ components: String...) -> Bool {
        
        for component in components {
            if self.contains(component) {
                return true
            }
        }
        
        return false
    }
    
}
