//
//  AppLogger.swift
//  
//
//  Created by Lennart Fischer on 22.04.22.
//

import Foundation
import OSLog

extension OSLog {
    
    /// Use the Bundle ID as the subsystem
    internal static var subsystem = Bundle.main.bundleIdentifier ?? "com.lambdadigamma.core"
    
    /// Application lifecycle
    public static let coreAppLifecycle = OSLog(subsystem: subsystem, category: "appLifecycle")
    
    /// API interactions
    public static let coreApi = OSLog(subsystem: subsystem, category: "api")
    
    /// UI
    public static let coreUi = OSLog(subsystem: subsystem, category: "ui")
    
    /// Local data & caches
    public static let coreLocalData = OSLog(subsystem: subsystem, category: "localdata")
    
    /// App Config
    public static let coreAppConfig = OSLog(subsystem: subsystem, category: "appconfig")
    
    /// Background - Stuff that happens in the background.
    public static let coreBackground = OSLog(subsystem: subsystem, category: "background")
    
}

/// Attention: This won't work with OSLog as it is using a
/// private compiler api that we are allowed to use.

/// Wrapping OSLogType in a custom AppLogType to make it possible to
/// swap the logger afterwards without changing an endless number of
/// log statements throughout the packages and app.
public struct AppLogType : Equatable, RawRepresentable {
    
    public var rawValue: UInt8
    
    public init(_ rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
}

extension AppLogType {
    
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static let `default`: AppLogType = AppLogType(1)
    
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static let info: AppLogType = AppLogType(2)
    
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static let debug: AppLogType = AppLogType(3)
    
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static let error: AppLogType = AppLogType(4)
    
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static let fault: AppLogType = AppLogType(5)
    
    public func toOSLogType() -> OSLogType {
        switch self.rawValue {
            case Self.default.rawValue:
                return OSLogType.default
            case Self.info.rawValue:
                return OSLogType.info
            case Self.debug.rawValue:
                return OSLogType.debug
            case Self.error.rawValue:
                return OSLogType.error
            case Self.fault.rawValue:
                return OSLogType.fault
            default:
                return OSLogType.default
        }
    }
    
}

internal class AppLogger {
    
//    private let logger: Logger = Logger(.default)
    
//    public func log(level: AppLogType = .default, message: OSLogMessage) {
//        logger.log(level: level.toOSLogType(), message)
//    }
    
}
