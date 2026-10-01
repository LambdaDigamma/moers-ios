//
//  AnyLocation.swift
//  Moers
//
//  Created by GitHub Copilot on 26.12.24.
//

import Foundation
import MapKit

/// Type-erased wrapper for Location protocol to enable Hashable conformance
nonisolated public struct AnyLocation: Hashable, Sendable {
    
    private let objectIdentifier: ObjectIdentifier
    
    public init(_ location: any Location) {
        self.objectIdentifier = ObjectIdentifier(location as AnyObject)
    }
}
