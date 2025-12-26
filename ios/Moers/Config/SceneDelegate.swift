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
    
    private let logger = Logger(.coreAppLifecycle)
    
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

        window!.rootViewController = applicationCoordinator.rootViewController()
        window!.makeKeyAndVisible()
        
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            
            if let stateRestorationActivity = session.stateRestorationActivity {
                logger.notice("State restoration of type \(stateRestorationActivity.activityType) received.")
            }
            
            self.applicationCoordinator.handle(userActivity: userActivity)
            
        }
        
    }
    
    // MARK: - State Restoration
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        
        if let activity = scene.userActivity ?? UserActivity.current {
            logger.info("Providing \(activity.activityType) for restoration purposes.")
            return activity
        }
        
        return nil
        
    }
    
    // MARK: - Handle Universal Links -
   
    /// Show user feedback while waiting for the NSUserActivity to arrive
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        
    }
    
    /// Set up view controllers and views to continue the activity
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        logger.info("Continueing user activity of type \(userActivity.activityType)")
        
        applicationCoordinator.handle(userActivity: userActivity)
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        logger.info("Received \(URLContexts.count) URLContexts")
        
        if let link = URLContexts.first?.url {
            logger.info("Opening a news article from widget")
            applicationCoordinator.openNewsArticle(url: link)
        }
        
    }
    
}
