//
//  BaseLaunchArgumentsHandler.swift
//  24doors
//
//  Created by Lennart Fischer on 12.01.21.
//  Copyright © 2021 LambdaDigamma. All rights reserved.
//

#if canImport(UIKit) && os(iOS)

import UIKit

@available(iOS 14.0, *)
open class BaseLaunchArgumentsHandler: @MainActor BootstrappingProcedureStep {
    
    /// Determine whether to remove all user defaults of
    /// the application bundle when supplying the reset flag.
    open var shouldClearUserDefaultsOnReset: Bool = false
    
    /// This is beeing used to determine whether the
    /// application is run in fastlane snapshotting mode.
    public static let isSnapshotting: Bool = UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    
    /// User Defaults act as a setting store for this application.
    public let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    /// React and add all settings
    @MainActor open func execute(with application: UIApplication) {
        
        #if DEBUG
        
        resetIfNeeded()
        setupSnapshotIfNeeded()
        
        #endif
        
    }
    
    /// There are development purposes (like automated screenshotting)
    /// when we need to delete and reset the whole application at the start.
    open func resetIfNeeded() {
        
        #if DEBUG
        
        guard CommandLine.arguments.contains("-reset") else {
            return
        }
        
        if shouldClearUserDefaultsOnReset {
            guard let defaultsName = Bundle.main.bundleIdentifier else { return }
            userDefaults.removePersistentDomain(forName: defaultsName)
        }
        
        // TODO: Add any reset specific code here.
        // For example clear all databases, caches, authentication, etc.
        
        #endif
        
    }
    
    /// Sets up all needed test data to generate automated screenshots
    /// for our AppStore page and marketing material.
    /// Override to populate data.
    @MainActor open func setupSnapshotIfNeeded() {
        
        guard BaseLaunchArgumentsHandler.isSnapshotting else { return }
        
        UIView.setAnimationsEnabled(false)
        
    }
    
}

#endif
