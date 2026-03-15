//
//  SceneDelegate.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.12.20.
//  Copyright © 2020 Code for Niederrhein. All rights reserved.
//

import Core
import UIKit
import OSLog
import FirebaseMessaging

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private let logger = Logger(.coreAppLifecycle)
    
    var window: UIWindow?
    var applicationController: ApplicationController?
    
    lazy var deeplinkCoordinator: DeeplinkCoordinatorProtocol = {
        return DeeplinkCoordinator(handlers: [
            EventsDeeplinkHandler(rootViewController: self.applicationController),
            FavoritesDeeplinkHandler(rootViewController: self.applicationController),
            NewsDeeplinkHandler(rootViewController: self.applicationController)
        ])
    }()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        applicationController = ApplicationController()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        window?.rootViewController = applicationController?.rootViewController()
        window?.makeKeyAndVisible()
        
        if let shortcutItem = connectionOptions.shortcutItem {
            applicationController?
                .tabBarController?
                .handle(shortcutItem: shortcutItem)
            return
        }
        
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            
            if let stateRestorationActivity = session.stateRestorationActivity {
                logger.notice("State restoration of type \(stateRestorationActivity.activityType) received.")
            }
            
            self.applicationController?.tabBarController?.handle(userActivity: userActivity)
            
        }
        
        if let response = connectionOptions.notificationResponse {
            
            processNotificationResponse(response: response)
            
        }
        
    }
    
    // MARK: - Scene Lifecycle -
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // MARK: - User Activity -
    
    /// Show user feedback while waiting for the NSUserActivity to arrive
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        
    }
    
    /// Set up view controllers and views to continue the activity
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        logger.info("Continueing user activity of type \(userActivity.activityType)")
        
        applicationController?.handle(userActivity: userActivity)
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        logger.info("Received \(URLContexts.count) URLContexts")
        
        if let link = URLContexts.first?.url {
            logger.info("Received url: \(link.absoluteString)")
            
            deeplinkCoordinator.handleURL(link)
        }
        
    }
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        
        
        applicationController?.tabBarController?.handle(shortcutItem: shortcutItem)
    }
    
    // MARK: - Process notification -
    
    internal func processNotificationResponse(response: UNNotificationResponse) {
        
        let content = response.notification.request.content
        
        if let deepLink = content.userInfo["deep_link"] as? String, let url = URL(string: deepLink) {
            deeplinkCoordinator.handleURL(url)
        }
        
    }
    
}

extension SceneDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    // MARK: - Apple Push Notification Service -
            
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//        }
//
//        print(userInfo)
//    }
    
    // MARK: - Firebase Cloud Messaging -
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        
        guard let fcmToken = fcmToken else {
            return
        }
        
        logger.info("Receive registration token \(fcmToken)")
        
        let tokenDict = ["token": fcmToken]
        
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: tokenDict
        )
        
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .sound, .badge, .list]])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        processNotificationResponse(response: response)
        
        completionHandler()
    }
    
}

