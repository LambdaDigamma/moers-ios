//
//  OtherViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import MessageUI
import FactoryKit
import SwiftUI
import AppFeedback
import RubbishFeature
import EFAAPI
import EFAUI
import MapFeature

public class OtherViewController: UIViewController {

    @LazyInjected(\.entryManager) private var entryManager
    
    public var coordinator: OtherCoordinator?
    
    private let standardCellIdentifier = "standard"
    private let accountCellIdentifier = "account"
    
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.insetGrouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OtherTableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        return tableView
        
    }()
    
    private lazy var data: [TableViewSection] = makeData()
    
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
        self.applyTheming()
        
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

    private func applyTheming() {
//        self.tableView.backgroundColor = UIColor.systemBackground
//        self.tableView.separatorColor = UIColor.separator
    }

    private func makeData() -> [TableViewSection] {

        var sections: [TableViewSection] = []

        if FeatureFlags.radioBuergerfunkEnabled {
            sections.append(TableViewSection(
                title: "Radio",
                rows: [
                    NavigationRow(title: "Bürgerfunk") { [weak self] in
                        self?.coordinator?.showBuergerfunk()
                    }
                ]
            ))
        }

        sections.append(TableViewSection(
            title: "ÖPNV",
            rows: [
                NavigationRow(title: "Fahrt planen (Beta)") { [weak self] in
                    self?.coordinator?.showTransportationOverview(animated: true)
                }
            ]
        ))

        sections.append(TableViewSection(
            title: String(localized: "Data"),
            rows: [
                NavigationRow(title: String(localized: "Add entry")) { [weak self] in
                    self?.coordinator?.showAddEntry()
                }
            ]
        ))

        sections.append(TableViewSection(
            title: String(localized: "Settings"),
            rows: [
                NavigationRow(title: String(localized: "Settings")) { [weak self] in
                    self?.coordinator?.showSettings()
                },
                NavigationRow(title: "Siri Shortcuts") { [weak self] in
                    self?.coordinator?.showSiriShortcuts()
                }
            ]
        ))

        sections.append(TableViewSection(
            title: "Info",
            rows: [
                NavigationRow(title: String(localized: "About")) { [weak self] in
                    self?.coordinator?.showAbout()
                },
                NavigationRow(title: String(localized: "Feedback")) { [weak self] in
                    self?.coordinator?.showFeedback()
                },
                NavigationRow(title: Bundle.main.versionString, action: nil)
            ]
        ))

        sections.append(TableViewSection(
            title: String(localized: "Legal"),
            rows: [
                NavigationRow(title: String(localized: "Terms and Conditions")) { [weak self] in
                    self?.coordinator?.showTaC()
                },
                NavigationRow(title: String(localized: "Privacy Policy")) { [weak self] in
                    self?.coordinator?.showPrivacy()
                },
                NavigationRow(title: String(localized: "Licences")) { [weak self] in
                    self?.coordinator?.showLicences()
                }
            ]
        ))

        #if DEBUG
        sections.append(TableViewSection(
            title: "Debug",
            rows: [
                NavigationRow(title: "Notifications") { [weak self] in
                    self?.coordinator?.showDebugNotifications()
                }
            ]
        ))
        #endif

        return sections

    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
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
            
            if let otherCell = cell as? OtherTableViewCell {
                otherCell.applyTheming()
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
    
    func applyTheming() {
        self.textLabel?.textColor = UIColor.label
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
