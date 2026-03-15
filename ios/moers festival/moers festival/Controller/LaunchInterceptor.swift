//
//  LaunchInterceptor.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.05.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import UIKit
import WhatsNewKit
import BLTNBoard
import AppScaffold
import SwiftUI
import MMEvents
import Combine

class LaunchInterceptor {
    
    lazy var bulletinManager: BLTNItemManager = {
        let introPage = BulletinDataSource.makeIntroPage()
        return BLTNItemManager(rootItem: introPage)
    }()
    
    private var firstLaunch: FirstLaunch
    private let currentBackground = (name: "Dimmed", style: BLTNBackgroundViewStyle.dimmed)
//    private var configuration = WhatsNewViewController.Configuration()
    
    private var cancellables = Set<AnyCancellable>()
    
    weak var viewController: UIViewController?
    
    private var downloadViewController: UIViewController?
    
    public init(firstLaunch: FirstLaunch) {
        self.firstLaunch = firstLaunch
        self.setupTheming()
        self.setupListener()
    }
    
    // MARK: - Setup -
    
    private func setupTheming() {
        
        self.bulletinManager.backgroundColor = UIColor.systemBackground
        self.bulletinManager.hidesHomeIndicator = false
        self.bulletinManager.edgeSpacing = .compact
        
//        configuration.backgroundColor = UIColor.systemBackground
//        configuration.titleView.titleColor = UIColor.label
//        configuration.detailButton?.titleColor = UIColor.secondaryLabel
//        configuration.completionButton.backgroundColor = AppColors.navigationAccent
//        configuration.completionButton.titleColor = AppColors.onAccent
//        configuration.itemsView.titleColor = UIColor.label
//        configuration.itemsView.subtitleColor = UIColor.secondaryLabel
//        configuration.itemsView.titleFont = .systemFont(ofSize: 17, weight: .semibold)
//        configuration.itemsView.subtitleFont = .systemFont(ofSize: 13, weight: .medium)
//        configuration.itemsView.animation = .fade
//        configuration.titleView.titleMode = .scrolls
//        configuration.titleView.insets = UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20)
//        configuration.completionButton.title = String.localized("WNCompletionText")
        
    }
    
    private func setupListener() {
        
        NotificationCenter.default.publisher(for: .SetupDidComplete)
            .sink { (notification: Notification) in
                
                AnalyticsManager.shared.logCompletedOnboarding()
                
                BulletinDataSource.userDidCompleteSetup = true
                
                self.checkMigration()
                self.showDownloadIfNeeded()
                
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - Logic -
    
    public func onAppear() {
        
        self.firstLaunch = FirstLaunch(userDefaults: .standard, key: Constants.wasLaunchedBefore)
        
        if firstLaunch.isFirstLaunch || !BulletinDataSource.userDidCompleteSetup {
            
            if !LaunchArguments().useMockedData() {
                showBulletin()
            }
            
        } else {
            
            if !LaunchArguments().useMockedData() {
                self.showDownloadIfNeeded()
                
                if LocationManager.shared.authorizationStatus == .notDetermined {
                    LocationManager.shared.requestWhenInUseAuthorization(completion: nil)
                }
            }
            
        }
        
        self.checkMigration()
        
    }
    
    private func checkMigration() {
        
        //        let waxwing = Waxwing(bundle: .main, defaults: .standard)
        
        //        waxwing.migrateToVersion("1.6") {
        //            showWhatsNew1_6()
        //        }
        //
        //        waxwing.migrateToVersion("1.7") {
        //            showWhatsNew1_6()
        //        }
        
    }
    
    private func showBulletin() {
        
        bulletinManager.backgroundViewStyle = currentBackground.style
        bulletinManager.statusBarAppearance = .hidden
        
        guard let viewController else { return }
        
        bulletinManager.showBulletin(above: viewController)
        
    }
    
    // MARK: - Whats New -
    
    private func showWhatsNew1_6() {
        
//        let whatsNew = WhatsNew(
//            // The Title
//            title: "moers festival 2021",
//            // The features you want to showcase
//            items: [
//                WhatsNew.Item(
//                    title: String.localized("WNItem1_6-1Title"),
//                    subtitle: String.localized("WNItem1_6-1Subtitle"),
//                    image: UIImage(named: "info")
//                ),
//                WhatsNew.Item(
//                    title: String.localized("WNItem1_6-2Title"),
//                    subtitle: String.localized("WNItem1_6-2Subtitle"),
//                    image: UIImage(named: "circled_play")
//                ),
//                WhatsNew.Item(
//                    title: String.localized("WNItem1_6-3Title"),
//                    subtitle: String.localized("WNItem1_6-3Subtitle"),
//                    image: UIImage(named: "money_box")
//                ),
//                WhatsNew.Item(
//                    title: String.localized("WNItem1_6-4Title"),
//                    subtitle: String.localized("WNItem1_6-4Subtitle"),
//                    image: UIImage(named: "heart")
//                )
//            ]
//        )
//        
//        let whatsNewViewController = WhatsNewViewController(
//            whatsNew: whatsNew,
//            configuration: configuration
//        )
//        
//        viewController?.present(whatsNewViewController, animated: true)
        
    }
    
    // MARK: - Offline Download -
    
    public func showDownloadIfNeeded() {
        
        guard !UserDefaults.standard.bool(forKey: "showedDownload") else {
            return
        }
        
        let downloadScreen = DownloadEventsScreen()
        let downloadViewController = UIHostingController(rootView: downloadScreen)
        
        let navigationController = UINavigationController(rootViewController: downloadViewController)
        
        downloadViewController.navigationItem.largeTitleDisplayMode = .never
        downloadViewController.isModalInPresentation = true
        downloadViewController.title = EventPackageStrings.Download.downloadTimetable
        
        let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeDownload))
        
        downloadViewController.navigationItem.leftBarButtonItems = [closeItem]
        
        self.downloadViewController = navigationController
        
        viewController?.present(navigationController, animated: true)
        
    }
    
    @objc private func closeDownload() {
        
        guard downloadViewController != nil else { return }
        
        UserDefaults.standard.set(true, forKey: "showedDownload")
        
        self.viewController?.dismiss(animated: true)
        
    }
    
}
