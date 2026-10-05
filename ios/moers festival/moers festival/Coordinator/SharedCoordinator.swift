//
//  SharedCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 25.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import MMEvents
import FactoryKit

public class SharedCoordinator: Coordinator {
    
    public var navigationController: CoordinatedNavigationController
    
    public var rootViewController: UIViewController { navigationController }
    
    public var tabBarItem: UITabBarItem? { rootViewController.tabBarItem }
    
    public weak var currentModalNavigationController: UINavigationController?

    public var activeNavigationController: UINavigationController {
        currentModalNavigationController ?? navigationController
    }
    
    public init(navigationController: CoordinatedNavigationController = .init()) {
        self.navigationController = navigationController
    }
    
    // MARK: - Actions -
    
    public func pushEventDetail(eventID: Event.ID, animated: Bool = true) {
        
        let usedNavigationController = activeNavigationController
        
        let detailController = ModernEventDetailViewController(
            eventID: eventID
        )
        
        detailController.coordinator = self
        
        usedNavigationController.pushViewController(detailController, animated: animated)
        
    }
    
    public func showEventDetail(eventID: Event.ID) {

        let detailController = ModernEventDetailViewController(
            eventID: eventID
        )

        detailController.coordinator = self
        detailController.showCloseButton = true

        let modalNavController = UINavigationController(rootViewController: detailController)
        modalNavController.modalPresentationStyle = .formSheet

        var presenter: UIViewController = activeNavigationController
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        presenter.present(modalNavController, animated: true)

    }
    
    public func pushPlaceDetail(placeID: Place.ID) {
        
        let usedNavigationController = activeNavigationController
        
        let viewController = VenueDetailController(placeID: placeID)
        viewController.coordinator = self
        
        usedNavigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showPlaceDetail(placeID: Place.ID, showCloseButton: Bool = true) {
        
        let viewController = VenueDetailController(placeID: placeID)
        viewController.coordinator = self
        viewController.modalPresentationStyle = .formSheet
        viewController.showCloseButton = showCloseButton
        
        let modalNavigationController = UINavigationController(rootViewController: viewController)
        modalNavigationController.modalPresentationStyle = .formSheet
        let presenter = activeNavigationController
        self.currentModalNavigationController = modalNavigationController
        presenter.present(modalNavigationController, animated: true)
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
