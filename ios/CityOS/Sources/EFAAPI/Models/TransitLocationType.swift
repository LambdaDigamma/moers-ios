//
//  AnyType.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation

public enum TransitLocationType: String, Codable, Hashable, Equatable {
    
    /// `anyTypeSort` of 1
    case location = "loc"
    
    /// `anyTypeSort` of 2
    case stop = "stop"
    
    /// `anyTypeSort` of 4
    case poi = "poi"
    
    /// `anyTypeSort` of 8
    case street = "street"
    
    /// `anyTypeSort` of 10
    case singlehouse = "singlehouse"
    
}
