//
//  PathHandling.swift
//  
//
//  Created by Lennart Fischer on 30.05.22.
//

import Foundation

public extension Collection where Element == String {
    
    func containsPathElement(_ components: String...) -> Bool {
        
        for component in components {
            if self.contains(component) {
                return true
            }
        }
        
        return false
    }
    
}

