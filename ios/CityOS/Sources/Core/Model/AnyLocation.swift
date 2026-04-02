//
//  AnyLocation.swift
//  Moers
//
//  Created by GitHub Copilot on 26.12.24.
//

import Foundation
import MapKit

/// Type-erased wrapper for Location protocol to enable Hashable conformance
public struct AnyLocation: Hashable, Sendable {
    
    private let base: any Location
    
    public init(_ location: any Location) {
        self.base = location
    }
    
    public var location: Location {
        return base
    }
    
    // Hashable conformance
    public static func == (lhs: AnyLocation, rhs: AnyLocation) -> Bool {
        return (lhs.base as AnyObject) === (rhs.base as AnyObject)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base as AnyObject))
    }
}
