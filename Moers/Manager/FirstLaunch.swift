//
//  FirstLaunch.swift
//  Moers
//
//  Created by Lennart Fischer on 14.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

public final class FirstLaunch {
    
    public let wasLaunchedBefore: Bool
    public var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    public init(
        getWasLaunchedBefore: () -> Bool,
        setWasLaunchedBefore: (Bool) -> Void
    ) {
        let wasLaunchedBefore = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            setWasLaunchedBefore(true)
        }
    }
    
    public convenience init(userDefaults: UserDefaults, key: String) {
        self.init(
            getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
            setWasLaunchedBefore: { userDefaults.set($0, forKey: key) }
        )
    }
    
}

public extension FirstLaunch {
    
    static func alwaysFirst() -> FirstLaunch {
        return FirstLaunch(getWasLaunchedBefore: { return false }, setWasLaunchedBefore: { _ in })
    }
    
}
