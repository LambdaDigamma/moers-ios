//
//  CoordinatedNavigationController.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

#if canImport(UIKit) && os(iOS)

import UIKit

@available(iOS 14.0, *)
open class CoordinatedNavigationController: UINavigationController {
    
    open weak var coordinator: Coordinator?
    
    open var menuItem: MenuItem? {
        
        didSet {
            
            guard let menuItem = menuItem else {
                tabBarItem = nil
                title = nil
                return
            }
            
            tabBarItem = UITabBarItem(
                title: menuItem.title,
                image: menuItem.image,
                selectedImage: nil
            )
            tabBarItem.accessibilityIdentifier = menuItem.accessibilityIdentifier
            
            title = menuItem.title
            
        }
        
    }
    
}

#endif
