//
//  Timestamps.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

/// Provides the two common fields when models where created and last updated.
public protocol Timestamps {
    
    /// The model was stored in the remote database at this point.
    var createdAt: Date? { get set }
    
    /// The last update this model got in the remote database.
    var updatedAt: Date? { get set }
    
}
