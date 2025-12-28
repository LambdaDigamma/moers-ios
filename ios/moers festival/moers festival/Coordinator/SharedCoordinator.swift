//
//  SharedCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 25.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import Resolver
import MMEvents

public class SharedCoordinator: Coordinator {
    
    public var navigationController: CoordinatedNavigationController
    
    public var currentModalNavigationController: UINavigationController?
    
    public init(navigationController: CoordinatedNavigationController = .init()) {
        self.navigationController = navigationController
    }
    
    // MARK: - Actions -
    
    public func pushEventDetail(eventID: Event.ID, animated: Bool = true) {
        
        let usedNavigationController = currentModalNavigationController ?? navigationController
        
        let eventService: LegacyEventService = Resolver.resolve()
        
        let detailController = ModernEventDetailViewController(
            eventID: eventID,
            eventService: eventService
        )
        
        detailController.coordinator = self
        
        DispatchQueue.main.async {
            usedNavigationController.pushViewController(detailController, animated: animated)
        }
        
    }
    
    public func pushPlaceDetail(placeID: Place.ID) {
        
        let usedNavigationController = currentModalNavigationController ?? navigationController
        
        let viewController = VenueDetailController(placeID: placeID)
        viewController.coordinator = self
        
        usedNavigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showPlaceDetail(placeID: Place.ID, showCloseButton: Bool = true) {
        
        let viewController = VenueDetailController(placeID: placeID)
        viewController.coordinator = self
        viewController.modalPresentationStyle = .formSheet
        viewController.showCloseButton = showCloseButton
        
        self.currentModalNavigationController = UINavigationController(rootViewController: viewController)
        self.currentModalNavigationController?.modalPresentationStyle = .formSheet
        self.navigationController.present(currentModalNavigationController!, animated: true)
        
    }
    
}
