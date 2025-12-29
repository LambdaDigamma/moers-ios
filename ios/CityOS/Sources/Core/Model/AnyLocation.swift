//
//  AnyLocation.swift
//  Moers
//
//  Created by GitHub Copilot on 26.12.24.
//

import Foundation
import MapKit

/// Type-erased wrapper for Location protocol to enable Hashable conformance
public struct AnyLocation: Hashable {
    
    private let base: any Location
    
    public init(_ location: any Location) {
        self.base = location
    }
    
    public var location: Location {
        return base
    }
    
    // Hashable conformance
    public static func == (lhs: AnyLocation, rhs: AnyLocation) -> Bool {
        // Compare by reference for reference types
        if let lhsObj = lhs.base as? AnyObject,
           let rhsObj = rhs.base as? AnyObject {
            return lhsObj === rhsObj
        }
        // Fallback to comparing names and coordinates for value types
        return lhs.base.name == rhs.base.name &&
               lhs.base.coordinate.latitude == rhs.base.coordinate.latitude &&
               lhs.base.coordinate.longitude == rhs.base.coordinate.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        // For reference types, use object identifier
        if let obj = base as? AnyObject {
            hasher.combine(ObjectIdentifier(obj))
        } else {
            // For value types, hash based on name and coordinate
            hasher.combine(base.name)
            hasher.combine(base.coordinate.latitude)
            hasher.combine(base.coordinate.longitude)
        }
    }
}
