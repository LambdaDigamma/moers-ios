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
import MMEvents
import SwiftUI

public class OtherCoordinator: Coordinator {
    
    public var navigationController: CoordinatedNavigationController
    
    public init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
        
        self.navigationController = navigationController
        
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.coordinator = self
        self.navigationController.menuItem = makeMenuItem()
        
        let otherViewController = OtherViewController()
        
        otherViewController.coordinator = self
        
        self.navigationController.viewControllers = [otherViewController]
        
    }
    
    // MARK: - Festival 21 Actions
    
    public func showVolunteers() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/volunteers/")!)
        
    }
    
    public func showTickets() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/tickets/")!)
        
//        let viewModel = TicketsListViewModel(mainTicket: Ticket.tickets2020[0],
//                                             dayTickets: Array(Ticket.tickets2020[5...8]),
//                                             moerzzTickets: Array(Ticket.tickets2020[1...4]),
//                                             vipTicket: Ticket.tickets2020[9],
//                                             earlyBirdTicket: Ticket.tickets2020[10])
//
//        let ticketsViewController = TicketsListViewController(viewModel: viewModel)
//        ticketsViewController.coordinator = self
//
//        self.navigationController.pushViewController(ticketsViewController, animated: true)
        
    }
    
    public func showFestivalDorf() {
        showPage(url: URL(string: "https://www.moers-festival.de/infos/festivaldorf/")!)
    }
    
    public func showMoersland() {
        showPage(url: URL(string: "https://www.moers-festival.de/moersland/")!)
    }
    
    public func showLodging() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/infos/schlafen/")!)
        
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
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func showLegal() {
        
        self.showBrowser(with: URL(string: "https://archiv.moers-festival.de/impressum")!)
        
    }
    
    public func showLicense() {
        
        let viewModel = LicensesViewModel()
        let viewController = LicensesViewController(viewModel: viewModel)
        
        viewController.coordinator = self
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    public func openReview() {
        
        let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/id1341448683?action=write-review")!
        
        UIApplication.shared.open(reviewURL)
        
    }
    
    public func openDeveloperLink(of type: DeveloperLinkType) {
        
        switch type {
            case .website:
                UIApplication.shared.open(URL(string: "https://lambdadigamma.com")!)
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
        
        self.navigationController.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: - Digital Festival
    
    public func showShop() {
        
        showPage(url: URL(string: "https://www.moers-festival.de/moerschandise/")!)
        
    }
    
    // MARK: - Utility
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController.pushViewController(vc, animated: true)
        
    }
    
    private func showBrowser(with url: URL) {
        
        let config = SFSafariViewController.Configuration()
        
        config.barCollapsingEnabled = true
        
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor.systemBackground
        vc.preferredControlTintColor = AppColors.navigationAccent
        
        navigationController.present(vc, animated: true)
        
    }
    
    private func makeStandardViewModel() -> OtherViewModel {
        
        let viewModel = OtherViewModel(sections: [])
        
        return viewModel
        
    }
    
    private func makeMenuItem() -> MenuItem {
        
        return MenuItem(
            title: AppStrings.Info.shortTitle,
            image: UIImage(systemName: "info.circle"),
            accessibilityIdentifier: AccessibilityIdentifiers.Menu.other
        )
        
    }
    
}
