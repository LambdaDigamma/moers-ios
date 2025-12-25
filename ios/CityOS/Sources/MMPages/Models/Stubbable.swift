//
//  Stubbable.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

public protocol Stubbable: Identifiable {

    static func stub(withID id: ID) -> Self

}

public extension Stubbable {

    func setting<T>(_ keyPath: WritableKeyPath<Self, T>,
                    to value: T) -> Self {
        var stub = self
        stub[keyPath: keyPath] = value
        return stub
    }

}

public extension Array where Element: Stubbable, Element.ID == Int {
    static func stub(withCount count: Int, startingAt: Int = 0) -> Array {
        return (startingAt..<count+startingAt).map {
            .stub(withID: $0)
        }
    }
}

extension Array where Element: Stubbable, Element.ID == String {
    static func stub(withCount count: Int, startingAt: Int = 0) -> Array {
        return (startingAt..<count + startingAt).map {
            .stub(withID: "\($0)")
        }
    }
}

public extension MutableCollection where Element: Stubbable {

    func setting<T>(_ keyPath: WritableKeyPath<Element, T>,
                    to value: T) -> Self {

        var collection = self

        for index in collection.indices {
            let element = collection[index]
            collection[index] = element.setting(keyPath, to: value)
        }

        return collection

    }

}

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
