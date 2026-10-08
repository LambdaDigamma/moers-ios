//
//  OtherCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import SafariServices
import INSPhotoGallery
import AppScaffold
import Events
import SwiftUI

public class OtherCoordinator: Coordinator {
    
    public var navigationController: CoordinatedNavigationController
    private let adaptiveSplitViewController: AdaptiveTabSplitViewController
    public var rootViewController: UIViewController { adaptiveSplitViewController }
    public var tabBarItem: UITabBarItem? { rootViewController.tabBarItem }

    public var activeNavigationController: UINavigationController {
        adaptiveSplitViewController.activeNavigationController
    }

    var selectedDetailViewController: UIViewController? { adaptiveSplitViewController.selectedDetailViewController }
    var showsDetailColumn: Bool { adaptiveSplitViewController.showsDetailColumn }
    
    public init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
        
        self.navigationController = navigationController
        navigationController.menuItem = Self.makeMenuItem()
        self.adaptiveSplitViewController = AdaptiveTabSplitViewController(
            overviewNavigationController: navigationController,
            emptyDetailFactory: {
                SplitDetailPlaceholderViewController(message: String(localized: "Select a topic to view its details."))
            }
        )
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        
        let otherViewController = OtherViewController()
        
        otherViewController.coordinator = self
        adaptiveSplitViewController.onDetailPresentationChange = { [weak otherViewController] in
            otherViewController?.updateSelection()
            otherViewController?.restoreScrollPosition()
        }
        adaptiveSplitViewController.onColumnsWillChange = { [weak otherViewController] in
            otherViewController?.retainScrollPosition()
        }
        
        self.navigationController.viewControllers = [otherViewController]
        
    }
    
    // MARK: - Festival 21 Actions
    
    public func showVolunteers() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/volunteers/")!)
        
    }
    
    public func showTickets() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/tickets/")!)
        
    }
    
    public func showFestivalDorf() {
        showPage(url: URL(string: "https://www.moers-festival.de/infos/festivaldorf/")!)
    }
    
    public func showMoersland() {
        showPage(url: URL(string: "https://www.moers-festival.de/moersland/")!)
    }
    
    public func showLodging() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/infos/schlafen-zelten-campen/")!)
        
//        let viewModel = TextViewModel(text: String.localized("LodgingInfoText"))
//        let viewController = TextViewController(viewModel: viewModel)
//
//        viewController.title = String.localized("LodgingHeading")
//        viewController.coordinator = self
//
//        AnalyticsManager.shared.logOpenLodging()
//
//        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showAccessibilty() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/infos/awareness-barrierefreiheit/")!)
        
//        let viewModel = TextViewModel(text: String.localized("AccessibilityInfoText"))
//        let viewController = TextViewController(viewModel: viewModel)
//
//        viewController.title = String.localized("AccessibilityHeading")
//        viewController.coordinator = self
//
//        AnalyticsManager.shared.logOpenAccessibility()
//
//        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showSponsor() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/f%C3%B6rdern/f%C3%B6rderer-partner/")!)
        
    }
    
    // MARK: - Other
    
    public func showAbout() {
        
        let viewController = AboutController(coordinator: self)
        
        adaptiveSplitViewController.setDetail({ viewController })
        
    }
    
    public func showLegal() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/start/impressum/")!)
        
    }
    
    public func showLicense() {
        
        let viewModel = LicensesViewModel()
        let viewController = LicensesViewController(viewModel: viewModel)
        
        viewController.coordinator = self
        
        adaptiveSplitViewController.setDetail({ viewController })
        
    }

    public func showDebugFCMToken() {

        let viewController = DebugFCMTokenViewController()

        adaptiveSplitViewController.setDetail({ viewController })

    }
    
    public func openReview() {
        
        let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/id1341448683?action=write-review")!
        
        UIApplication.shared.open(reviewURL)
        
    }
    
    public func openDeveloperLink(of type: DeveloperLinkType) {
        
        switch type {
            case .website:
                UIApplication.shared.open(URL(string: "https://lennartfischer.dev")!)
            case .twitter:
                UIApplication.shared.open(URL(string: "https://twitter.com/lambdadigamma")!)
            case .instagram:
                UIApplication.shared.open(URL(string: "https://instagram.com/lennartfischer")!)
        }
        
    }
    
    public func showDownload() {
        
        let downloadScreen = DownloadEventsScreen()
        let viewController = UIHostingController(rootView: downloadScreen)
        
        viewController.navigationItem.largeTitleDisplayMode = .never
        
        adaptiveSplitViewController.setDetail({ viewController })
        
    }
    
    // MARK: - Digital Festival
    
    public func showShop() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/moerschandise/")!)
        
    }
    
    // MARK: - Utility

    public func showOverview(animated: Bool = false) {
        rootViewController.dismiss(animated: false)
        adaptiveSplitViewController.showEmptyDetail(animated: animated)
    }

    public func showPage(url: URL) {
        adaptiveSplitViewController.setDetail({ makeWebViewController(url: url) })
    }

    private func makeWebViewController(url: URL) -> FallbackWebViewController {
        let controller = FallbackWebViewController(url: url)
        controller.navigationItem.largeTitleDisplayMode = .never
        controller.navigationCallback = { [weak self, weak controller] nextURL in
            guard let self, let controller else { return }
            self.adaptiveSplitViewController.pushDetail({ self.makeWebViewController(url: nextURL) }, from: controller)
        }
        return controller
    }
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController.pushViewController(vc, animated: true)
        
    }
    
    private func makeStandardViewModel() -> OtherViewModel {
        
        let viewModel = OtherViewModel(
            hero: OtherHeroContent(
                title: "",
                subtitle: "",
                symbolName: "info.circle.fill",
                iconStyle: .indigo
            ),
            sections: []
        )
        
        return viewModel
        
    }
    
    private static func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.Info.shortTitle,
            image: UIImage(systemName: "info.circle"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.other
        )
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

#if DEBUG
#Preview("Info & Tickets, wide", traits: .fixedLayout(width: 951, height: 669)) {
    let controller = OtherCoordinator().rootViewController
    controller.traitOverrides.horizontalSizeClass = .regular
    return controller
}

#Preview("Info & Tickets, narrow", traits: .fixedLayout(width: 466, height: 678)) {
    let controller = OtherCoordinator().rootViewController
    controller.traitOverrides.horizontalSizeClass = .compact
    return controller
}
#endif
