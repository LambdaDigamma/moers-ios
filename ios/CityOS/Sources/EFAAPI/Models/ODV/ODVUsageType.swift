//
//  ODVUsageType.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public enum ODVUsageType: String, Codable {
    
    case origin = "origin"
    case destination = "destination"
    case via = "via"
    case dm = "dm"
    case sf = "sf"
    
}
