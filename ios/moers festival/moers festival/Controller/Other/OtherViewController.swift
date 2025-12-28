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
        
        self.viewModel = OtherViewModel(sections: loadSections())
        
        otherView = OtherView(viewModel: viewModel)
        view = otherView
        
        otherView.setTableViewDelegate(self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.navigationItem.title = String.localized("InfoTabItem")
        
    }
    
    private func setupTheming() {
        
        self.bulletinBackgroundColor = UIColor.systemBackground
        
    }
    
    private func loadSections() -> [Section] {
        
        var sections =  [
            Section(
                title: String.localized("FestivalHeading"),
                rows: [
                    Row(title: EventPackageStrings.Download.downloadTimetable, action: coordinator?.showDownload),
                    Row(title: String.localized("TicketsTitle"), action: coordinator?.showTickets),
                    Row(title: "Festivaldorf", action: coordinator?.showFestivalDorf),
                    Row(title: "Volunteers", action: coordinator?.showVolunteers),
//                    Row(title: "FAQ", action: coordinator?.showFAQ),
                    Row(title: "moersland", action: coordinator?.showMoersland),
//                    Row(title: "Team", action: coordinator?.showTeam),
//                    Row(title: "451", action: coordinator?.show451),
                    Row(title: String.localized("LodgingHeading"), action: coordinator?.showLodging),
                                    
//                    Row(title: "Moers Festival Express", action: coordinator?.showMFESchedule),
//                    Row(title: String.localized("TicketsTitle"), action: coordinator?.showTickets),
//                    Row(title: String.localized("LodgingHeading"), action: coordinator?.showLodging),
                    Row(title: String.localized("AccessibilityHeading"), action: coordinator?.showAccessibilty),
//                    Row(title: "Ticket spenden / zurückgeben", action: coordinator?.showDonateTicket),
                                    
                    Row(title: "moerschandise", action: coordinator?.showShop),
                    Row(title: String.localized("SponsorTitle"), action: coordinator?.showSponsor)
                ]
            ),
             Section(
                title: String.localized("OtherTabItem"),
                rows: [
                    Row(title: String.localized("AboutTitle"), action: coordinator?.showAbout),
                    Row(title: String.localized("LegalTitle"), action: coordinator?.showLegal),
                    Row(title: String.localized("LicensesTitle"), action: coordinator?.showLicense),
                    Row(title: String.localized("StaffLoginTitle"), action: showStaffLogin)
                ]
             )
        ]
        
        if AdminManager.shared.isAdmin {
            
            sections[2].rows.removeLast()
            sections.append(
                Section(
                    title: "Mitarbeiter",
                    rows: [
                        Row(
                            title: "Push Benachrichtigungen",
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

extension OtherViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let action = viewModel.rowAction(for: indexPath)
        
        action?()
        
    }
    
}
