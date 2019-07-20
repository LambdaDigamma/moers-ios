//
//  TabControllerFactory.swift
//  Moers
//
//  Created by Lennart Fischer on 19.07.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import UIKit
import ESTabBarController

struct TabControllerFactory {
    
    func buildNavigationController(
        using controller: UIViewController,
        tabItem: UITabBarItem
    ) -> UINavigationController {
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [controller]
        
        navigationController.tabBarItem = tabItem
        
        return navigationController
        
    }
    
    func buildTabItem(
        using contentView: ESTabBarItemContentView,
        title: String? = nil,
        image: UIImage? = nil,
        accessibilityLabel: String = "",
        accessibilityIdentifier: String = ""
    ) -> UITabBarItem {
        
        let tabBarItem = ESTabBarItem(contentView,
                                      title: title,
                                      image: image,
                                      selectedImage: image)
        
        tabBarItem.accessibilityTraits = [.tabBar, .button]
        tabBarItem.accessibilityLabel = accessibilityLabel
        tabBarItem.accessibilityIdentifier = accessibilityIdentifier
        
        return tabBarItem
        
    }
    
    
}
