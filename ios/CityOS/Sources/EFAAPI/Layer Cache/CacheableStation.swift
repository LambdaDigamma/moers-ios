//
//  CacheableStation.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation
import Core

public protocol CacheableStation: Codable, Identifiable {
    
    var name: String { get set }
    
    var coordinates: Point? { get }
    
}
