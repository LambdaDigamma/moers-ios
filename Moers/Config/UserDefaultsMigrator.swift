//
//  UserDefaultsMigrator.swift
//  Moers
//
//  Created by Lennart Fischer on 02.02.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation
import OSLog

@objc public extension UserDefaults {
    
    private static let migrator = UserDefaultsMigrator(
        from: .standard,
        to: UserDefaults(suiteName: Constants.appGroupSuiteName) ?? .standard
    )
    
    static let appGroup: UserDefaults = {
        migrator.migrate()
        return migrator.defaults()
    }()
    
}

public final class UserDefaultsMigrator: NSObject {
    
    private let from: UserDefaults
    private let to: UserDefaults
    private let logger: Logger = Logger(.default)
    
    private var hasMigrated = false
    
    public init(from: UserDefaults, to: UserDefaults) {
        self.from = from
        self.to = to
    }
    
    /// Returns the proper defaults to be used by the application
    public func defaults() -> UserDefaults {
        return to
    }
    
    public func migrate() {
        
        let userDefaults = from
        let groupDefaults = to
        
        // Don't migrate if they are the same defaults!
        if userDefaults == groupDefaults {
            return
        }
        
        logger.info("Trying to migrate user defaults to app group")
        
        // Key to track if we migrated
        let didMigrateToAppGroups = "DidMigrateToAppGroups"
        
        if !groupDefaults.bool(forKey: didMigrateToAppGroups) {
            
            // Doing this loop because in practice we might want to filter things (I did), instead of a straight migration
            for key in userDefaults.dictionaryRepresentation().keys {
                groupDefaults.set(userDefaults.dictionaryRepresentation()[key], forKey: key)
            }
            groupDefaults.set(true, forKey: didMigrateToAppGroups)
            
        }
        
    }
    
}
