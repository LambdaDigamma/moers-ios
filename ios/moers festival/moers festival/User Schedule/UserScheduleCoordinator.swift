//
//  UserScheduleCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold

class UserScheduleCoordinator: SharedCoordinator {

    override init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        super.init(navigationController: navigationController)
        
        self.navigationController = navigationController
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        self.navigationController.menuItem = makeMenuItem()
        
        let tabBarItem = UITabBarItem(
            title: self.navigationController.menuItem?.title,
            image: self.navigationController.menuItem?.image,
            selectedImage: nil
        )
        
        let viewController = UserScheduleViewController()
        
//        viewController.coordinator = self
        viewController.tabBarItem = tabBarItem
        viewController.title = AppStrings.UserSchedule.title
        
        self.navigationController.viewControllers = [viewController]
        
    }
    
    func rootViewController() -> UIViewController {
        navigationController
    }
    
    private func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.UserSchedule.title,
            image: UIImage(named: "user-schedule.badge.clock"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.userSchedule
        )
        
    }
    
}
