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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var applicationController: ApplicationCoordinator!
    
    private let logger = Logger(.default)
    
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
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        logger.info("Continueing user activity of type \(userActivity.activityType)")
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            handleUniversalLinks(from: userActivity)
        }
        
        if userActivity.activityType == RubbishFeature.PackageUserActivity.rubbishScheduleActivityIdentifier {
            openRubbishScheduleDetails()
        }
        
    }
    
    private func handleUniversalLinks(from userActivity: NSUserActivity) {
        
        logger.info("Trying to handle universal link.")
        
        guard let url = userActivity.webpageURL,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        logger.info("Handling universal link: \(url.absoluteString)")
        
        if components.path.contains("/abfallkalender") {
            return openRubbishScheduleDetails()
        }
        
        if components.path.contains("/tanken") || components.path.contains("/fuel") {
            return openFuelStationList()
        }
        
        if components.path.contains("/news") || components.path.contains("/nachrichten") {
            return switchToNews()
        }
        
        if components.path.contains("/events") || components.path.contains("/veranstaltungen") {
            return switchToEvents()
        }
        
        if components.path.contains("/settings") || components.path.contains("/einstellungen") {
            return openSettings()
        }
        
        if components.path.contains("/bürgerfunk") || components.path.contains("/buergerfunk") {
            return openBuergerfunk()
        }
        
    }
    
    private func openRubbishScheduleDetails() {
        applicationController.tabController.selectedIndex = TabIndices.dashboard.rawValue
        applicationController.tabController.navigationController?.popToRootViewController(animated: true)
        applicationController.tabController.dashboard.pushRubbishViewController()
    }
    
    private func openFuelStationList() {
        applicationController.tabController.selectedIndex = TabIndices.dashboard.rawValue
        applicationController.tabController.navigationController?.popToRootViewController(animated: true)
        applicationController.tabController.dashboard.pushFuelStationListViewController()
    }
    
    private func switchToNews() {
        applicationController.tabController.news.navigationController.popToRootViewController(animated: true)
        applicationController.tabController.selectedIndex = TabIndices.news.rawValue
    }
    
    private func switchToEvents() {
        applicationController.tabController.events.navigationController.popToRootViewController(animated: true)
        applicationController.tabController.selectedIndex = TabIndices.events.rawValue
    }
    
    private func openSettings() {
        applicationController.tabController.selectedIndex = TabIndices.other.rawValue
        applicationController.tabController.navigationController?.popToRootViewController(animated: true)
        applicationController.tabController.other.showSettings()
    }
    
    private func openBuergerfunk() {
        applicationController.tabController.selectedIndex = TabIndices.other.rawValue
        applicationController.tabController.navigationController?.popToRootViewController(animated: true)
        applicationController.tabController.other.showBuergerfunk()
    }
    
}
