//
//  LaunchArgumentsHandler.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import ModernNetworking
import MMFeeds

public class LaunchArgumentsHandler: BaseLaunchArgumentsHandler {
    
    public static var shouldUseMockedFeed: Bool = {
        return false
    }()
    
    public static var shouldUseMockedTour: Bool = {
        return true
    }()
    
    public static var shouldUseMockedEvents: Bool = {
        return true
    }()
    
}
