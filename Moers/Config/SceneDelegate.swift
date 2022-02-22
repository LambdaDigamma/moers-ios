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
    public var applicationController: ApplicationCoordinator!
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        
        self.applicationController = ApplicationCoordinator()

        window!.overrideUserInterfaceStyle = .dark
        window!.rootViewController = applicationController.rootViewController()
        window!.makeKeyAndVisible()
        
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                applicationController.handleUniversalLinks(from: userActivity)
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
            applicationController.handleUniversalLinks(from: userActivity)
        }
        
        if userActivity.activityType == UserActivities.IDs.rubbishSchedule
            || userActivity.activityType == WidgetKinds.rubbish.rawValue {
            applicationController.openRubbishScheduleDetails()
        }
        
    }
    
    
    
    private func openRubbishScheduleDetails() {
//        applicationController.tabController.selectedIndex = TabIndices.dashboard.rawValue
//        applicationController.tabController.navigationController?.popToRootViewController(animated: true)
//        applicationController.tabController.dashboard.pushRubbishViewController()
    }
    
    private func openFuelStationList() {
//        applicationController.tabController.selectedIndex = TabIndices.dashboard.rawValue
//        applicationController.tabController.navigationController?.popToRootViewController(animated: true)
//        applicationController.tabController.dashboard.pushFuelStationListViewController()
    }
    
    private func switchToNews() {
//        applicationController.tabController.news.navigationController.popToRootViewController(animated: true)
//        applicationController.tabController.selectedIndex = TabIndices.news.rawValue
    }
    
    private func switchToEvents() {
//        applicationController.tabController.events.navigationController.popToRootViewController(animated: true)
//        applicationController.tabController.selectedIndex = TabIndices.events.rawValue
    }
    
    private func openSettings() {
//        applicationController.tabController.selectedIndex = TabIndices.other.rawValue
//        applicationController.tabController.navigationController?.popToRootViewController(animated: true)
//        applicationController.tabController.other.showSettings()
    }
    
    private func openBuergerfunk() {
//        applicationController.tabController.selectedIndex = TabIndices.other.rawValue
//        applicationController.tabController.navigationController?.popToRootViewController(animated: true)
//        applicationController.tabController.other.showBuergerfunk()
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
