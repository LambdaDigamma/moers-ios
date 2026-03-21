//
//  FirstLaunch.swift
//  
//
//  Created by Lennart Fischer on 03.01.21.
//

import Foundation

public final class FirstLaunch {
    
    public let wasLaunchedBefore: Bool
    public var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    public init(
        getWasLaunchedBefore: () -> Bool,
        setWasLaunchedBefore: (Bool) -> ()
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

extension FirstLaunch {
    
    public static func alwaysFirst() -> FirstLaunch {
        return FirstLaunch(getWasLaunchedBefore: { return false }, setWasLaunchedBefore: { _ in })
    }
    
}
