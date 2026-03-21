//
//  ApplicationController.swift
//  
//
//  Created by Lennart Fischer on 03.01.21.
//

#if canImport(UIKit) && os(iOS)

import UIKit

@available(iOS 14.0, *)
public protocol ApplicationControlling {
    
    var firstLaunch: FirstLaunch { get set }
    var config: AppConfigurable { get set }
    
    func rootViewController() -> UIViewController
    
}

@available(iOS 14.0, *)
extension ApplicationControlling {
    
    @MainActor func rootViewController() -> UIViewController {
        
        return UIViewController()
        
    }
    
}

#endif
