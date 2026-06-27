//
//  Stubbable.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation

nonisolated public protocol Stubbable: Identifiable {
    
    static func stub(withID id: ID) -> Self
    
}

public extension Stubbable {
    
    nonisolated func setting<T>(_ keyPath: WritableKeyPath<Self, T>,
                                to value: T) -> Self {
        var stub = self
        stub[keyPath: keyPath] = value
        return stub
    }
    
}

public extension Array where Element: Stubbable, Element.ID == Int {
    nonisolated static func stub(withCount count: Int, startingAt: Int = 0) -> Array {
        return (startingAt..<count+startingAt).map {
            .stub(withID: $0)
        }
    }
}

extension Array where Element: Stubbable, Element.ID == String {
    nonisolated static func stub(withCount count: Int, startingAt: Int = 0) -> Array {
        return (startingAt..<count+startingAt).map {
            .stub(withID: "\($0)")
        }
    }
}

public extension MutableCollection where Element: Stubbable {
    
    nonisolated func setting<T>(_ keyPath: WritableKeyPath<Element, T>,
                                to value: T) -> Self {
        
        var collection = self
        
        for index in collection.indices {
            let element = collection[index]
            collection[index] = element.setting(keyPath, to: value)
        }
        
        return collection
        
    }
    
}
