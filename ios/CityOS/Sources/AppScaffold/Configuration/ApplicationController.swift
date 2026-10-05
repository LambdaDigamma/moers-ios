//
//  ApplicationController.swift
//  
//
//  Created by Lennart Fischer on 03.01.21.
//

#if canImport(UIKit) && os(iOS)

import UIKit

public protocol ApplicationControlling {
    
    var firstLaunch: FirstLaunch { get set }
    var config: AppConfigurable { get set }
    
    func rootViewController() -> UIViewController
    
}

extension ApplicationControlling {
    
    @MainActor func rootViewController() -> UIViewController {
        
        return UIViewController()
        
    }
    
}

#endif
