//
//  LaunchArgumentsHandler.swift
//  Moers
//
//  Created by Lennart Fischer on 23.07.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import Foundation
import Haneke

struct LaunchArgumentsHandler {
    let userDefaults: UserDefaults
    
    func handle() {
        
        resetIfNeeded()
        
        #if DEBUG
        if isSnapshotting() {
            UIView.setAnimationsEnabled(false)
        }
        #endif
        
    }

    private func resetIfNeeded() {
        
        guard CommandLine.arguments.contains("-reset") else {
            return
        }
        
        let defaultsName = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: defaultsName)
        
        Shared.dataCache.removeAll()
        
    }
    
    private func isSnapshotting() -> Bool {
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    }
    
}
