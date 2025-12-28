//
//  LiveCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AppScaffold

public class LiveCoordinator: Coordinator {
    
    public var navigationController: CoordinatedNavigationController
    
    public init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
    
        self.navigationController = navigationController
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        self.navigationController.menuItem = makeMenuItem()
        
        let viewController = FestivalLiveController() // LiveOverviewViewController()
        
//        viewController.coordinator = self
        
        self.navigationController.viewControllers = [viewController]
        
    }
    
    private func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.Live.title,
            image: UIImage(systemName: "play.circle")
        )
        
    }
    
}
