//
//  LaunchArguments.swift
//  MoersUITests
//
//  Created by Lennart Fischer on 11.02.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation

public let fastlaneSnapshotArgument = "FASTLANE_SNAPSHOT"

public struct LaunchArgument {
    
    public let name: String
    
    public var boolValue: Bool {
        UserDefaults.standard.bool(forKey: name)
    }
    
    public var stringValue: String? {
        UserDefaults.standard.string(forKey: name)
    }
    
    public var intValue: Int {
        UserDefaults.standard.integer(forKey: name)
    }
    
}

enum LaunchArguments {
    
    enum Common {
        static let isUITesting = LaunchArgument(name: "isUITesting")
        static let isFastlaneSnapshot = LaunchArgument(name: fastlaneSnapshotArgument)
        static let animations = LaunchArgument(name: "animations")
        /// Use a `ISO8601` conforming string like "2021-12-03T21:10:56Z"
        static let currentUIDate = LaunchArgument(name: "currentUIDate")
        /// Use a language tag to set the simulator language
        static let language = LaunchArgument(name: "AppleLanguages")
    }
    
}
