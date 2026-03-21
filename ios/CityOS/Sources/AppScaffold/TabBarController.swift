//
//  TabBarController.swift
//  
//
//  Created by Lennart Fischer on 31.03.22.
//

#if canImport(UIKit) && os(iOS)
import UIKit
import Combine

@available(iOS 14.0, *)
open class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    public var cancellables = Set<AnyCancellable>()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

#endif
