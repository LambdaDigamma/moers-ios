//
//  DashboardCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 12.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import AppScaffold
import SwiftUI
import DashboardFeature
import RubbishFeature
import FuelFeature
import EFAAPI
import EFAUI
import CoreLocation

public class DashboardCoordinator: Coordinator {
    
    public var navigationController: CoordinatedNavigationController
    
    let observer = DefaultLocationTransitStationObserver()
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        
        self.navigationController = navigationController
        self.navigationController.coordinator = self
        
        let dashboard = DashboardView(openCurrentTrip: {
            self.openTrip()
        }) {
//            if #available(iOS 16.0, *) {
//                WeatherWidget()
//            }
        }
        
        let controller = UIHostingController(rootView: dashboard)
        let activity = UserActivities.configureDashboardActivity()
        
        controller.tabBarItem = generateTabBarItem()
        controller.userActivity = activity
        controller.navigationItem.rightBarButtonItems = [
            .init(image: UIImage(systemName: "slider.vertical.3"), style: .plain, target: self, action: #selector(showEditDashboard))
        ]
        
        activity.becomeCurrent()
        
        self.navigationController.viewControllers = [controller]
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
        self.setupLocationListener()
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.dashboard,
            image: UIImage(systemName: "doc.text.image"), // "rectangle.grid.2x2"
            selectedImage: UIImage(systemName: "doc.text.image") // "rectangle.grid.2x2.fill"
        )
        
        tabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.dashboard
        
        return tabBarItem
        
    }
    
    // MARK: - Navigation
    
    public func pushRubbishViewController() {
        
        let rubbishCollectionViewController = RubbishScheduleController()
        
        navigationController.popToRootViewController(animated: true)
        navigationController.pushViewController(rubbishCollectionViewController, animated: true)
        
    }
    
    public func pushFuelStationListViewController() {
        
        let fuelStationListViewController = FuelStationListViewController()
        
        navigationController.popToRootViewController(animated: true)
        navigationController.pushViewController(fuelStationListViewController, animated: true)
        
    }
    
    public func updateUI() {
        
        NotificationCenter.default.post(name: .updateDashboard, object: nil)
        
    }
    
    private func setupLocationListener() {
        
        observer.stationFinder(coordinate: CLLocationCoordinate2D(latitude: 50.76772, longitude: 6.09205))
        
    }
    
    @objc private func showEditDashboard() {
        
        let viewController = EditDashboardViewController()
        
        navigationController.pushViewController(viewController, animated: true)
        
    }
    
    private func openTrip() {
        
        let viewController = TripExperienceViewController()
        let navigation = UINavigationController(rootViewController: viewController)
        
        navigation.isModalInPresentation = true
        
        viewController.navigationItem.leftBarButtonItems = [
            .init(systemItem: .close, primaryAction: UIAction(handler: { action in
                self.navigationController.dismiss(animated: true)
            }))
        ]
        
        viewController.onCancel = {
            self.navigationController.dismiss(animated: true)
        }
        
        navigationController.present(navigation, animated: true)
        
    }
    
}
