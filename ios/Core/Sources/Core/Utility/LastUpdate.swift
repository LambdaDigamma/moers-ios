//
//  LastUpdate.swift
//  
//
//  Created by Lennart Fischer on 31.05.22.
//

import Foundation

public extension TimeInterval {
    
    static func minutes(_ value: Double) -> TimeInterval {
        return TimeInterval(60) * value
    }
    
}

public class LastUpdate {
    
    private let key: String
    private let defaults: UserDefaults
    
    private var defaultsKey: String {
        "last_update_\(key)"
    }
    
    public init(key: String, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }
    
    public func get() -> Date? {
        if let dateString = defaults.string(forKey: defaultsKey) {
            return Self.dateFormatter.date(from: dateString)
        }
        return nil
    }
    
    public func set(to value: Date?) {
        if let date = value {
            let dateString = Self.dateFormatter.string(from: date)
            defaults.set(dateString, forKey: defaultsKey)
        } else {
            reset()
        }
    }
    
    public func setNow() {
        set(to: Date())
    }
    
    public func shouldReload(ttl: TimeInterval) -> Bool {
        
        guard let lastReload = get() else { return true }
        
        let now = Date()
        let timeIntervalSinceLastReload = now.timeIntervalSince(lastReload)
        
        if timeIntervalSinceLastReload > ttl {
            return true
        }
        
        return false
        
    }
    
    public func reset() {
        defaults.set(nil, forKey: defaultsKey)
    }
    
    public static let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter
    }()
    
}
