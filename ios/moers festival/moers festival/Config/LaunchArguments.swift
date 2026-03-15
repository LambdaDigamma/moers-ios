//
//  LaunchArguments.swift
//  moers festival
//
//  Created by Lennart Fischer on 01.05.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import Factory

public class LaunchArguments {
    
    private let keyUseMockedData = "mocked"
    
    public func useMockedData() -> Bool {
        return CommandLine.arguments.contains("-mocked")
//        return UserDefaults.standard.bool(forKey: keyUseMockedData)
    }
    
}
