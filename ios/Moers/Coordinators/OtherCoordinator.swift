//
//  OtherCoordinator.swift
//  Moers
//
//  Created by Lennart Fischer on 14.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import AppScaffold
import EFAUI
import EFAAPI
import AppFeedback
import MapFeature
// import Resolver - removed (migrated to Factory)

public class OtherCoordinator: Coordinator {
    
    @LazyInjected var entryManager: EntryManagerProtocol
    
    public var navigationController: CoordinatedNavigationController
    public var otherViewController: OtherViewController?
    public let transitService: DefaultTransitService
    
    public init(
        navigationController: CoordinatedNavigationController = CoordinatedNavigationController()
    ) {
        
        self.navigationController = navigationController
        self.transitService = DefaultTransitService(loader: DefaultTransitService.defaultLoader())
        
        let otherViewController = OtherViewController()
        
        otherViewController.tabBarItem = generateTabBarItem()
        otherViewController.coordinator = self
        
        self.navigationController.coordinator = self
        self.navigationController.viewControllers = [otherViewController]
        self.otherViewController = otherViewController
        
        Styling.applyStyling(navigationController: navigationController, statusBarStyle: .darkContent)
        
    }
    
    private func generateTabBarItem() -> UITabBarItem {
        
        let tabBarItem = UITabBarItem(
            title: AppStrings.Menu.other,
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )
        
        tabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.Menu.other
        
        return tabBarItem
        
    }
    
    // MARK: - Actions -
    
    public func showBuergerfunk() {
        
        let viewController = RadioBroadcastsViewController()
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showSettings() {
        
        let settingsViewController = SettingsViewController()
        
        navigationController.pushViewController(settingsViewController, animated: true)
        
    }
    
    public func showTransportationOverview(animated: Bool = false) {
        
        self.navigationController.popToRootViewController(animated: animated)
        
        let viewController = TripConfigurationViewController()
        
        self.navigationController.pushViewController(viewController, animated: animated)
        
    }
    
    public func showDepartureMonitor(animated: Bool = false) {

        let viewController = StopDepartureViewController(rootView: StopDepartureScreen())
        
        self.navigationController.pushViewController(viewController, animated: animated)
        
    }
    
    public func showTransporationSearch(data: TripSearchActivityData? = nil) {
        
        self.showTransportationOverview()
        
        let viewModel = TripSearchViewModel(transitService: transitService)
        
        if let data = data {
            viewModel.originID = data.originID
            viewModel.destinationID = data.destinationID
        }
        
        viewModel.search()
        
        let viewController = TripSearchViewController(viewModel: viewModel)
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: - Data Actions -
    
    public func showAddEntry() {
        
        if entryManager.entryStreet != nil || entryManager.entryLat != nil {
            
            let alert = UIAlertController(
                title: String.localized("OtherDataTakeOldDataTitle"),
                message: String.localized("OtherDataTakeOldDataMessage"),
                preferredStyle: .alert
            )
            
            alert.overrideUserInterfaceStyle = .dark
            
            alert.addAction(
                UIAlertAction(
                    title: String.localized("OtherDataTakeOldDataNo"),
                    style: .cancel,
                    handler: { _ in
                        self.entryManager.resetData()
                        
                        let viewController = EntryOnboardingLocationMenuViewController()
                        
                        self.navigationController.pushViewController(viewController, animated: true)
                    }
                )
            )
            
            alert.addAction(
                UIAlertAction(
                    title: String.localized("OtherDataTakeOldDataYes"),
                    style: .default,
                    handler: { _ in
                        let viewController = EntryOnboardingLocationMenuViewController()
                        
                        self.navigationController.pushViewController(viewController, animated: true)
                    }
                )
            )
            
            self.navigationController
                .presentedViewController?
                .present(alert, animated: true, completion: nil)
            
        } else {
            
            let viewController = EntryOnboardingLocationMenuViewController()
            
            self.navigationController.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    public func showNonValidData() {
        
        let viewController = EntryValidationViewController(otherCoordinator: self)
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: - Settings Actions -
    
    public func showSiriShortcuts() {
        
        let viewController = ShortcutsViewController()
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: - About Actions -
    
    public func showAbout() {
        
        let viewController = AboutViewController()
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showFeedback() {
        
        let configuration = FeedbackConfiguration(
            receiver: "meinmoers@lambdadigamma.com",
            subject: "Rückmeldung zur Moers-App",
            appStoreID: "1305862555"
        )
        
        let feedbackView = FeedbackViewController(configuration: configuration)
        
        self.navigationController.pushViewController(feedbackView, animated: true)
        
    }
    
    public func showLicences() {
        
        let viewController = LicencesViewController()
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showPrivacy() {
        
        let viewController = PrivacyViewController()
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showTaC() {
        
        let viewController = TandCViewController()
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: - Debug Actions -
    
    public func showDebugNotifications() {
        
        let viewController = DebugViewController()
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
}
