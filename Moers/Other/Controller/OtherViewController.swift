//
//  OtherViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MessageUI
import MMAPI
import MMUI
import SwiftUI

class OtherViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var coordinator: OtherCoordinator?
    
    private let isWaterTemperatureEnabled = false
    
    private let standardCellIdentifier = "standard"
    private let accountCellIdentifier = "account"
    private var backgroundColor: UIColor = .clear
    private var textColor: UIColor = .clear
    
    private var entryManager: EntryManagerProtocol
    private let locationManager: LocationManagerProtocol
    private let geocodingManager: GeocodingManagerProtocol
    private let rubbishManager: RubbishManagerProtocol
    private let petrolManager: PetrolManagerProtocol
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OtherTableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        return tableView
        
    }()
    
    lazy var data: [TableViewSection] = {
        
        var additionalData: [TableViewSection] = []
        
        if #available(iOS 13.0, *) {
            if isWaterTemperatureEnabled {
                additionalData.append(contentsOf: [
                    TableViewSection(title: "Moers Funk", rows: [
                        NavigationRow(title: "Bettenkamper Wassertemperatur", action: showWaterTemperature)
                    ])
                ])
            }
        }
        
        var normalData = [
            
            TableViewSection(title: "Radio",
                             rows: [NavigationRow(title: "Bürgerfunk",
                                                  action: showBuergerfunkSchedule)]),
            
            TableViewSection(title: String.localized("OtherSectionDataTitle"),
                    rows: [NavigationRow(title: String.localized("OtherSectionDataAddEntry"),
                                         action: showAddEntry)]),
            TableViewSection(title: String.localized("SettingsTitle"),
                    rows: [NavigationRow(title: String.localized("SettingsTitle"),
                                         action: showSettings),
                           NavigationRow(title: "Siri Shortcuts",
                                         action: showSiriShortcuts)]),
            TableViewSection(title: "Info",
                    rows: [NavigationRow(title: String.localized("AboutTitle"),
                                         action: showAbout),
                           NavigationRow(title: String.localized("Feedback"),
                                         action: showFeedback),
                           NavigationRow(title: Bundle.main.versionString,
                                         action: nil)]),
            
            TableViewSection(title: String.localized("Legal"),
                    rows: [NavigationRow(title: String.localized("TandC"),
                                         action: showTaC),
                           NavigationRow(title: String.localized("PrivacyPolicy"),
                                         action: showPrivacy),
                           NavigationRow(title: String.localized("Licences"),
                                         action: showLicences)])
        ]
        
        #if DEBUG
        normalData.append(TableViewSection(
            title: "Debug",
            rows: [
                NavigationRow(
                    title: "Notifications",
                    action: showDebugNotifications
                )
            ]
        ))
        #endif
        
        return additionalData + normalData
        
    }()
    
    init(
        locationManager: LocationManagerProtocol,
        geocodingManager: GeocodingManagerProtocol,
        rubbishManager: RubbishManagerProtocol,
        petrolManager: PetrolManagerProtocol,
        entryManager: EntryManagerProtocol
    ) {
    
        self.locationManager = locationManager
        self.geocodingManager = geocodingManager
        self.rubbishManager = rubbishManager
        self.petrolManager = petrolManager
        self.entryManager = entryManager
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String.localized("OtherTabItem")
        
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        AnalyticsManager.shared.logOpenedOther()
        
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    // MARK: - Row Action
    
    private func showBuergerfunkSchedule() {
        
        let viewController = RadioBroadcastsViewController()
//        let viewController = RadioViewController()
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    private func showAddEntry() {
        
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
                        
                        let viewController = EntryOnboardingLocationMenuViewController(locationManager: self.locationManager,
                                                                                       entryManager: self.entryManager)
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                )
            )
            
            alert.addAction(
                UIAlertAction(
                    title: String.localized("OtherDataTakeOldDataYes"),
                    style: .default,
                    handler: { _ in
                        let viewController = EntryOnboardingLocationMenuViewController(locationManager: self.locationManager,
                                                                                       entryManager: self.entryManager)
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                )
            )
            
            present(alert, animated: true, completion: nil)
            
        } else {
            
            let viewController = EntryOnboardingLocationMenuViewController(locationManager: self.locationManager,
                                                                           entryManager: self.entryManager)
            
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    private func showNonValidData() {
        push(viewController: EntryValidationViewController.self)
    }
    
    private func showSettings() {
        
        let settingsViewController = SettingsViewController(locationManager: locationManager,
                                                            geocodingManager: geocodingManager,
                                                            rubbishMananger: rubbishManager,
                                                            petrolManager: petrolManager)
        
        navigationController?.pushViewController(settingsViewController, animated: true)
        
    }
    
    private func showSiriShortcuts() {
        push(viewController: ShortcutsViewController.self)
    }
    
    private func showAbout() {
        push(viewController: AboutViewController.self)
    }
    
    private func showFeedback() {
        
        if MFMailComposeViewController.canSendMail() {
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["meinmoers@lambdadigamma.com"])
            mail.setSubject("Rückmeldung zur Moers-App")
            
            present(mail, animated: true)
            
        } else {
            
            let alert = UIAlertController(
                title: "Feedback fehlgeschlagen",
                message: "Du hast scheinbar keine Email-Accounts auf deinem Gerät eingerichtet.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    private func showTaC() {
        push(viewController: TandCViewController.self)
    }
    
    private func showPrivacy() {
        push(viewController: PrivacyViewController.self)
    }
    
    private func showLicences() {
        push(viewController: LicensesViewController.self)
    }
    
    private func showDebugNotifications() {
        
        push(viewController: DebugNotificationViewController.self)
        
    }
    
    // MARK: - Moers Funk
    
    @available(iOS 13.0, *)
    private func showWaterTemperature() {
        
        let temperatureView = TemperatureView()
        let hosting = UIHostingController(rootView: temperatureView)
        
        hosting.title = "Temperatur"
        
        self.navigationController?.pushViewController(hosting, animated: true)
        
    }
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

extension OtherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data[section].rows.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow {
            
            cell = tableView.dequeueReusableCell(withIdentifier: standardCellIdentifier)!
            
            cell.textLabel?.text = navigationRow.title
            cell.accessoryType = .disclosureIndicator
            
            if let cell = cell as? OtherTableViewCell {
                MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: cell)
            }
            
        } else {
            cell = UITableViewCell()
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow {
            
            navigationRow.action?()
            
        }
        
    }
    
}

public class OtherTableViewCell: UITableViewCell {
    
}

extension OtherViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.textColor = theme.color
        self.backgroundColor = UIColor.systemBackground // theme.backgroundColor
        self.tableView.backgroundColor = UIColor.systemBackground // theme.backgroundColor
        self.tableView.separatorColor = UIColor.separator // theme.separatorColor
    }
    
}

extension OtherTableViewCell: Themeable {
    
    public typealias Theme = ApplicationTheme
    
    public func apply(theme: Theme) {
        self.backgroundColor = UIColor.systemBackground // theme.backgroundColor
        self.textLabel?.textColor = theme.color
    }
    
}
