//
//  OtherViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import Gestalt
import MessageUI
import MMUI
import Resolver
import SwiftUI
import AppFeedback
import RubbishFeature
import EFAAPI
import EFAUI
import MapFeature

public class OtherViewController: UIViewController {

    @LazyInjected private var entryManager: EntryManagerProtocol
    
    public var coordinator: OtherCoordinator?
    
    private let standardCellIdentifier = "standard"
    private let accountCellIdentifier = "account"
    private var backgroundColor: UIColor = .clear
    private var textColor: UIColor = .clear
    
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OtherTableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        return tableView
        
    }()
    
    private lazy var data: [TableViewSection] = {
        
        var normalData = [
            
            FeatureFlags.radioBuergerfunkEnabled ?
                TableViewSection(
                    title: "Radio",
                    rows: [
                        NavigationRow(
                            title: "Bürgerfunk",
                            action: coordinator?.showBuergerfunk ?? {}
                        )
                    ]
                ) : nil,
            
            TableViewSection(
                title: "ÖPNV",
                rows: [
                    NavigationRow(
                        title: "Fahrt planen",
                        action: {
                            self.coordinator?.showTransportationOverview(animated: true)
                        }
                    )
                ]
            ),
            
            TableViewSection(
                title: String.localized("OtherSectionDataTitle"),
                rows: [
                    NavigationRow(
                        title: String.localized("OtherSectionDataAddEntry"),
                        action: coordinator?.showAddEntry ?? {}
                    )
                ]
            ),
            TableViewSection(
                title: String.localized("SettingsTitle"),
                rows: [
                    NavigationRow(
                        title: String.localized("SettingsTitle"),
                        action: coordinator?.showSettings ?? {}
                    ),
                    NavigationRow(
                        title: "Siri Shortcuts",
                        action: coordinator?.showSiriShortcuts ?? {}
                    )
                ]
            ),
            TableViewSection(
                title: "Info",
                rows: [
                    NavigationRow(
                        title: String.localized("AboutTitle"),
                        action: coordinator?.showAbout ?? {}
                    ),
                    NavigationRow(
                        title: String.localized("Feedback"),
                        action: coordinator?.showFeedback ?? {}
                    ),
                    NavigationRow(
                        title: Bundle.main.versionString,
                        action: nil
                    )
                ]
            ),
            TableViewSection(
                title: String.localized("Legal"),
                rows: [
                    NavigationRow(
                        title: String.localized("TandC"),
                        action: coordinator?.showTaC ?? {}
                    ),
                    NavigationRow(
                        title: String.localized("PrivacyPolicy"),
                        action: coordinator?.showPrivacy ?? {}
                    ),
                    NavigationRow(
                        title: String.localized("Licences"),
                        action: coordinator?.showLicences ?? {}
                    )
                ]
            )
        ].compactMap { $0 }
        
        #if DEBUG
        normalData.append(TableViewSection(
            title: "Debug",
            rows: [
                NavigationRow(
                    title: "Notifications",
                    action: coordinator?.showDebugNotifications ?? {}
                )
            ]
        ))
        #endif
        
        return normalData
        
    }()
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = AppStrings.Menu.other
        
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        AnalyticsManager.shared.logOpenedOther()
        UserActivity.current = UserActivities.configureOther()
        
    }
    
    // MARK: - Setup -
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
}

extension OtherViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data[section].rows.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow {
            
            navigationRow.action?()
            
        }
        
    }
    
}

public class OtherTableViewCell: UITableViewCell {
    
}

extension OtherViewController: Themeable {
    
    public typealias Theme = ApplicationTheme
    
    public func apply(theme: Theme) {
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
