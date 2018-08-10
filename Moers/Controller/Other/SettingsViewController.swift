//
//  SettingsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import BLTNBoard

class SettingsViewController: UIViewController {

    private let standardCellIdentifier = "standard"
    private let switchCellIdentifier = "switchCell"
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: switchCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        ThemeManager.default.apply(theme: Theme.self, to: tableView) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.separatorColor = theme.decentColor
        }
        
        return tableView
        
    }()
    
    var data: [Section] {
        
        let hour = RubbishManager.shared.reminderHour
        let minute = RubbishManager.shared.reminderMinute
        
        var rubbishReminder: String
        
        if let hour = hour, let minute = minute, let enabled = RubbishManager.shared.remindersEnabled, enabled {
            
            var hourString = ""
            var minuteString = ""
            
            if hour < 10 {
                hourString += "0\(hour)"
            } else {
                hourString += "\(hour)"
            }
            
            if minute < 10 {
                minuteString += "0\(minute)"
            } else {
                minuteString += "\(minute)"
            }
            
            rubbishReminder = String.localized("ReminderText") + ": \(hourString):\(minuteString)"
            
        } else {
            rubbishReminder = String.localized("ReminderText") + ": " + String.localized("NotActivated")
        }
        
        return [Section(title: String.localized("UIAdjustments"),
                        rows: [NavigationRow(title: String.localized("ThemeTitle"), action: showThemes)]),
                Section(title: String.localized("SettingsRubbishCollectionTitle"),
                        rows: [SwitchRow(title: String.localized("Activated"), switchOn: RubbishManager.shared.isEnabled, action: triggerRubbishCollection),
                               NavigationRow(title: String.localized("Street") + ": \(RubbishManager.shared.rubbishStreet?.street ?? "nicht ausgewählt")", action: showRubbishStreet),
                               NavigationRow(title: rubbishReminder, action: showRubbishReminder)]
            )
        ]
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("SettingsTitle")
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [tableView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
    private func showThemes() {
        push(viewController: ThemeViewController.self)
    }
    
    private func showRubbishStreet() {
        
        let streetPage = OnboardingManager.shared.makeRubbishStreetPage()
        let manager = BLTNItemManager(rootItem: streetPage)
        
        ThemeManager.default.apply(theme: Theme.self, to: manager) { themeable, theme in
            
            themeable.backgroundColor = theme.backgroundColor
            themeable.hidesHomeIndicator = false
            themeable.edgeSpacing = .compact
            
        }
        
        manager.backgroundViewStyle = .dimmed
        manager.statusBarAppearance = .hidden
        manager.showBulletin(above: self)
        
        streetPage.actionHandler = { item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            let selectedStreet = item.streets[item.picker.currentSelectedRow]
            
            RubbishManager.shared.register(selectedStreet)
            
            self.tableView.reloadData()
            
            manager.dismissBulletin(animated: true)
            
        }
        
        streetPage.alternativeHandler = { item in
            manager.dismissBulletin(animated: true)
        }
        
    }
    
    private func showRubbishReminder() {
        
        let reminderPage = OnboardingManager.shared.makeRubbishReminderPage()
        let manager = BLTNItemManager(rootItem: reminderPage)
        
        ThemeManager.default.apply(theme: Theme.self, to: manager) { themeable, theme in
            
            themeable.backgroundColor = theme.backgroundColor
            themeable.hidesHomeIndicator = false
            themeable.edgeSpacing = .compact
            
        }
        
        manager.backgroundViewStyle = .dimmed
        manager.statusBarAppearance = .hidden
        manager.showBulletin(above: self)
        
        reminderPage.alternativeButtonTitle = "Deaktivieren"
        
        reminderPage.actionHandler = { item in
            
            guard let page = item as? RubbishReminderBulletinItem else { return }
            
            let hour = Calendar.current.component(.hour, from: page.picker.date)
            let minutes = Calendar.current.component(.minute, from: page.picker.date)
            
            RubbishManager.shared.registerNotifications(at: hour, minute: minutes)
            
            self.tableView.reloadData()
            
            manager.dismissBulletin(animated: true)
            
        }
        
        reminderPage.alternativeHandler = { item in
            
            RubbishManager.shared.remindersEnabled = false
            RubbishManager.shared.reminderHour = 20
            RubbishManager.shared.reminderMinute = 0
            
            self.tableView.reloadData()
            
            manager.dismissBulletin(animated: true)
            
        }
        
    }
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func triggerRubbishCollection(isEnabled: Bool) {
        RubbishManager.shared.isEnabled = isEnabled
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            
            
        } else {
            
            let switchRow = data[indexPath.section].rows[indexPath.row] as? SwitchRow
            
            let switchCell = tableView.dequeueReusableCell(withIdentifier: switchCellIdentifier) as! SwitchTableViewCell
            
            switchCell.descriptionLabel.text = switchRow?.title
            switchCell.switchControl.isOn = switchRow?.switchOn ?? false
            switchCell.action = switchRow?.action
            
            cell = switchCell
            
        }
        
        cell.selectionStyle = .none
        
        ThemeManager.default.apply(theme: Theme.self, to: cell) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.textLabel?.textColor = theme.color
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow else { return }
        
        navigationRow.action?()
        
    }
    
}
