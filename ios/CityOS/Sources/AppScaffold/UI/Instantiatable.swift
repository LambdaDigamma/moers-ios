//
//  Instantiatable.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

#if canImport(UIKit) && os(iOS)

import UIKit

protocol Instantiatable {
    static func instantiate() -> Self
}

extension Instantiatable where Self: UIViewController {
    
    @MainActor internal static func instantiate() -> Self {
        
        let newViewController = Self()
        
        return newViewController
        
    }
    
}

#endif
