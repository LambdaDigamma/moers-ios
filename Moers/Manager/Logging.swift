//
//  Logging.swift
//  Moers
//
//  Created by Lennart Fischer on 11.09.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import OSLog

extension OSLog {
    
    /// Use the Bundle ID as the subsystem
    internal static var subsystem = Bundle.main.bundleID
    
    /// Application lifecycle
    internal static let appLifecycle = OSLog(subsystem: subsystem, category: "appLifecycle")
    
    /// API interactions
    internal static let api = OSLog(subsystem: subsystem, category: "api")
    
    /// UI
    internal static let ui = OSLog(subsystem: subsystem, category: "ui")
    
    /// Local data & caches
    internal static let localData = OSLog(subsystem: subsystem, category: "localdata")
    
    /// App Config
    internal static let appConfig = OSLog(subsystem: subsystem, category: "appconfig")
    
    /// Background - Stuff that happens in the Background.
    internal static let background = OSLog(subsystem: subsystem, category: "background")
    
}
