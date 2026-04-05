//
//  OtherViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import BLTNBoard
import INSPhotoGallery
import MMEvents

class OtherViewController: UIViewController {

    public var coordinator: OtherCoordinator?
    
    private lazy var isAdmin = { AdminManager.shared.isAdmin }()
    private lazy var manager = { createAdminManager() }()
    
    private var otherView: OtherView!
    private var viewModel: OtherViewModel!
    
    private var bulletinBackgroundColor: UIColor?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.setupTheming()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func loadView() {
        
        self.viewModel = OtherViewModel(
            hero: OtherHeroContent(
                title: String.localized("Info for your festival visit"),
                subtitle: String.localized("Everything you need to know about tickets, the festival village, volunteers, and other festival-related services."),
                symbolName: "info.circle.fill",
                iconStyle: .indigo
            ),
            sections: loadSections()
        )
        
        otherView = OtherView(viewModel: viewModel)
        view = otherView
        
        otherView.setCollectionViewDelegate(self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.navigationItem.title = String.localized("Info & Tickets")
        
    }
    
    private func setupTheming() {
        
        self.bulletinBackgroundColor = UIColor.systemBackground
        
    }
    
    private func loadSections() -> [Section] {
        
        var sections =  [
            Section(
                title: String.localized("The festival"),
                rows: [
                    Row(title: EventPackageStrings.Download.downloadTimetable, symbolName: "arrow.down.circle.fill", iconStyle: .blue, action: coordinator?.showDownload),
                    Row(title: String.localized("Tickets"), symbolName: "ticket.fill", iconStyle: .orange, action: coordinator?.showTickets),
                    Row(title: String.localized("Festival Village"), symbolName: "map.fill", iconStyle: .green, action: coordinator?.showFestivalDorf),
                    Row(title: "Volunteers", symbolName: "person.2.fill", iconStyle: .indigo, action: coordinator?.showVolunteers),
//                    Row(title: "FAQ", action: coordinator?.showFAQ),
                    Row(title: "moersland", symbolName: "sparkles", iconStyle: .mint, action: coordinator?.showMoersland),
//                    Row(title: "Team", action: coordinator?.showTeam),
//                    Row(title: "451", action: coordinator?.show451),
                    Row(title: String.localized("Lodging"), symbolName: "bed.double.fill", iconStyle: .teal, action: coordinator?.showLodging),
                                    
//                    Row(title: "Moers Festival Express", action: coordinator?.showMFESchedule),
//                    Row(title: String.localized("TicketsTitle"), action: coordinator?.showTickets),
//                    Row(title: String.localized("LodgingHeading"), action: coordinator?.showLodging),
                    Row(title: String.localized("Awareness and Accessibility"), symbolName: "accessibility", iconStyle: .blue, action: coordinator?.showAccessibilty),
//                    Row(title: "Ticket spenden / zurückgeben", action: coordinator?.showDonateTicket),
                                    
                    Row(title: "moerschandise", symbolName: "bag.fill", iconStyle: .pink, action: coordinator?.showShop),
                    Row(title: String.localized("Partner"), symbolName: "heart.text.square.fill", iconStyle: .red, action: coordinator?.showSponsor)
                ]
            ),
             Section(
                title: String.localized("Other"),
                rows: [
                    Row(title: String.localized("About"), symbolName: "info.circle.fill", iconStyle: .blue, action: coordinator?.showAbout),
                    Row(title: String.localized("Legal"), symbolName: "doc.text.fill", iconStyle: .gray, action: coordinator?.showLegal),
                    Row(title: String.localized("Licenses"), symbolName: "curlybraces.square.fill", iconStyle: .gray, action: coordinator?.showLicense),
                    Row(title: String.localized("Staff Login"), symbolName: "person.badge.key.fill", iconStyle: .gray, action: showStaffLogin)
                ]
             )
        ]
        
        if AdminManager.shared.isAdmin {
            
            sections[2].rows.removeLast()
            sections.append(
                Section(
                    title: String.localized("Staff"),
                    rows: [
                        Row(
                            title: String.localized("Push Notifications"),
                            symbolName: "bell.badge.fill",
                            iconStyle: .red,
                            action: showPushNotificationPage
                        )
                    ]
                )
            )
            
        }
        
        return sections
        
    }
    
    private func createAdminManager() -> BLTNItemManager {
        
        let staffPage = BulletinDataSource.makeStaffLoginPage(completion: { (success) in
            
            if success {
                
                self.isAdmin = AdminManager.shared.isAdmin
                
                // TODO: Rebuild DataSource
                
                self.otherView.update()
                
            }
            
        })
        
        let pushNotification = BulletinDataSource.makeNotificationBuilderPage()
        
        return BLTNItemManager(rootItem: isAdmin ? pushNotification : staffPage)
        
    }
    
    private func showStaffLogin() {
        
        AnalyticsManager.shared.logOpenedStaffLogin()
        
        manager.backgroundColor = bulletinBackgroundColor ?? .white
        manager.hidesHomeIndicator = false
        manager.edgeSpacing = .compact
        manager.backgroundViewStyle = BLTNBackgroundViewStyle.dimmed
        manager.statusBarAppearance = .hidden
        manager.showBulletin(above: self)
        
    }
    
    private func showPushNotificationPage() {
        
        manager.backgroundColor = bulletinBackgroundColor ?? .white
        manager.hidesHomeIndicator = false
        manager.edgeSpacing = .compact
        manager.backgroundViewStyle = .dimmed
        manager.statusBarAppearance = .hidden
        manager.showBulletin(above: self)
        
    }
    
}

extension OtherViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let action = otherView.rowAction(for: indexPath)
        
        action?()
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
    
}
