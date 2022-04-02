//
//  FileManager+Extensions.swift
//  
//
//  Created by Lennart Fischer on 02.04.22.
//

import Foundation

public extension FileManager {
    
    func removeItemIfExists(at url: URL) throws {
        
        if fileExists(atPath: url.path) {
            try removeItem(at: url)
        }
        
    }
    
}
