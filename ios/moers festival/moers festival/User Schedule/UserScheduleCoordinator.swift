//
//  UserScheduleCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import MMEvents

class UserScheduleCoordinator: SharedCoordinator {

    private let userScheduleViewController: UserScheduleViewController
    private let adaptiveSplitViewController: AdaptiveTabSplitViewController?

    public override var rootViewController: UIViewController {
        adaptiveSplitViewController ?? navigationController
    }
    
    public override var tabBarItem: UITabBarItem? { rootViewController.tabBarItem }

    override init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        self.userScheduleViewController = UserScheduleViewController()
        self.adaptiveSplitViewController = UIDevice.current.userInterfaceIdiom == .pad
            ? AdaptiveTabSplitViewController(
                overviewNavigationController: navigationController,
                emptyDetailFactory: Self.makeEmptyDetailViewController
            )
            : nil

        super.init(navigationController: navigationController)
        
        self.navigationController = navigationController
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        self.navigationController.menuItem = makeMenuItem()
        self.adaptiveSplitViewController?.tabBarItem = self.navigationController.tabBarItem
        self.adaptiveSplitViewController?.title = self.navigationController.title
        
        let tabBarItem = UITabBarItem(
            title: self.navigationController.menuItem?.title,
            image: self.navigationController.menuItem?.image,
            selectedImage: nil
        )
        
        userScheduleViewController.onShowEvent = { [weak self] eventID in
            self?.showDetail(for: eventID)
        }

        userScheduleViewController.tabBarItem = tabBarItem
        userScheduleViewController.title = AppStrings.UserSchedule.title
        
        self.navigationController.viewControllers = [userScheduleViewController]
        
    }

    override func pushEventDetail(eventID: Event.ID, animated: Bool = true) {
        showDetail(for: eventID, animated: animated)
    }

    func showDetail(for eventID: Event.ID, animated: Bool = true) {
        let detailFactory = { [unowned self] in
            self.makeEventDetailViewController(eventID: eventID)
        }

        if let adaptiveSplitViewController {
            adaptiveSplitViewController.setDetail(detailFactory, animated: animated)
        } else if let rootViewController = navigationController.viewControllers.first {
            navigationController.setViewControllers([rootViewController, detailFactory()], animated: false)
        }
    }

    func showOverview(animated: Bool = false) {
        if let adaptiveSplitViewController {
            adaptiveSplitViewController.showEmptyDetail(animated: animated)
        } else {
            navigationController.popToRootViewController(animated: animated)
        }
    }
    
    private func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.UserSchedule.title,
            image: UIImage(named: "user-schedule.badge.clock"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.userSchedule
        )
        
    }

    private func makeEventDetailViewController(eventID: Event.ID) -> UIViewController {
        let detailController = ModernEventDetailViewController(eventID: eventID)
        detailController.coordinator = self
        return detailController
    }

    private static func makeEmptyDetailViewController() -> UIViewController {
        SplitDetailPlaceholderViewController(message: String(localized: "Select an event to view its details."))
    }
    
}
