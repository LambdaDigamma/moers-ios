//
//  UserDefaultsBacked.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

@propertyWrapper public struct UserDefaultsBacked<Value> {
    
    public let key: String
    public let defaultValue: Value
    public var storage: UserDefaults = .standard
    
    public init(key: String, defaultValue: Value, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
    
    public var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.setValue(newValue, forKey: key)
            }
        }
    }
    
}

extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    
    public init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, storage: storage)
    }
    
}
