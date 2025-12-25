//
//  Collection+Extensions.swift
//  MMAPI
//
//  Created by Lennart Fischer on 30.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

public extension Array where Element: Stubbable, Element.ID == Int {
    static func stub(withCount count: Int) -> Array {
        return (0..<count).map {
            .stub(withID: $0)
        }
    }
}

extension Array where Element: Stubbable, Element.ID == String {
    static func stub(withCount count: Int) -> Array {
        return (0..<count).map {
            .stub(withID: "\($0)")
        }
    }
}

extension Array {
    
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
    
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
}
