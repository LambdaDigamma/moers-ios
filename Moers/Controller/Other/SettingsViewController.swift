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
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: switchCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        ThemeManager.default.apply(theme: Theme.self, to: tableView) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.separatorColor = theme.separatorColor
        }
        
        return tableView
        
    }()
    
    lazy var manager: BLTNItemManager = { makeManager(with: BLTNPageItem(title: "")) }()
    
    var data: [Section] = []
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String.localized("SettingsTitle")
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.reloadRows()
        
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let constraints = [tableView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    // MARK: - Settings Rows
    
    private func showThemes() {
        push(viewController: ThemeViewController.self)
    }
    
    private func showRubbishStreet() {
        
        let streetPage = OnboardingManager.shared.makeRubbishStreetPage()
        
        streetPage.actionHandler = { item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            let selectedStreet = item.streets[item.picker.currentSelectedRow]
            
            RubbishManager.shared.register(selectedStreet)
            
            self.reload()
            
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
            
        }
        
        streetPage.alternativeHandler = { item in
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
        }
        
        self.manager.showBulletin(above: self)
        self.manager.push(item: streetPage)
        
    }
    
    private func showRubbishReminder() {
        
        let reminderPage = OnboardingManager.shared.makeRubbishReminderPage()
        
        reminderPage.alternativeButtonTitle = "Deaktivieren"
        reminderPage.actionHandler = { item in
            
            guard let page = item as? RubbishReminderBulletinItem else { return }
            
            let hour = Calendar.current.component(.hour, from: page.picker.date)
            let minutes = Calendar.current.component(.minute, from: page.picker.date)
            
            RubbishManager.shared.invalidateRubbishReminderNotifications()
            RubbishManager.shared.registerNotifications(at: hour, minute: minutes)
            
            self.reloadRows()
            
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
            
        }
        
        reminderPage.alternativeHandler = { item in
            
            RubbishManager.shared.disableReminder()
            
            self.reloadRows()
            
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
            
        }
        
        self.manager.showBulletin(above: self)
        self.manager.push(item: reminderPage)
        
    }
    
    private func showPetrolType() {
        
        guard let petrolTypePage = OnboardingManager.shared.makePetrolType(preSelected: PetrolManager.shared.petrolType) as? SelectorBulletinPage<PetrolType> else { return }
        
        petrolTypePage.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
            self.reload()
        }
        
        self.manager.showBulletin(above: self)
        self.manager.push(item: petrolTypePage)
        
    }
    
    private func showUserType() {
        
        guard let userTypePage = OnboardingManager.shared.makeUserTypePage(preSelected: UserManager.shared.user.type) as? SelectorBulletinPage<User.UserType> else { return }
        
        userTypePage.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
            self.reload()
        }
        
        self.manager.showBulletin(above: self)
        self.manager.push(item: userTypePage)
        
    }
    
    // MARK: - Utilities
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func reloadRows() {
        
        let hour = RubbishManager.shared.reminderHour
        let minute = RubbishManager.shared.reminderMinute
        
        var rubbishReminder: String
        
        if let hour = hour, let minute = minute, RubbishManager.shared.remindersEnabled {
            
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
        
        let userType = UserManager.shared.user.type
        
        var sections: [Section] = []
        
        sections.append(Section(title: String.localized("UIAdjustments"),
                                rows: [NavigationRow(title: String.localized("ThemeTitle"), action: showThemes)]))
        
        sections.append(Section(title: String.localized("User"),
                                rows: [NavigationRow(title: String.localized("UserType") + ": " + User.UserType.localizedForCase(userType), action: showUserType)]))
        
        sections.append(Section(title: String.localized("Petrol"),
                                rows: [NavigationRow(title: String.localized("PetrolType") + ": " + PetrolType.localizedForCase(PetrolManager.shared.petrolType), action: showPetrolType)]))
        
        if UserManager.shared.user.type == .citizen {
            
            sections.append(Section(title: String.localized("SettingsRubbishCollectionTitle"),
                                    rows: [SwitchRow(title: String.localized("Activated"),
                                                     switchOn: RubbishManager.shared.isEnabled,
                                                     action: triggerRubbishCollection),
                                           NavigationRow(title: String.localized("Street") + ": \(RubbishManager.shared.rubbishStreet?.street ?? "nicht ausgewählt")",
                                            action: showRubbishStreet),
                                           NavigationRow(title: rubbishReminder,
                                                         action: showRubbishReminder)]))
            
        }
        
        self.data = sections
        
        self.tableView.reloadData()
        
    }
    
    private func reload() {
        
        self.reloadRows()
        
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        
        tabBarController.dashboardViewController.reloadUI()
        
    }
    
    private func triggerRubbishCollection(isEnabled: Bool) {
        
        RubbishManager.shared.isEnabled = isEnabled
        RubbishManager.shared.disableReminder()
        
        self.reloadRows()
        
    }
    
    private func makeManager(with item: BLTNItem) -> BLTNItemManager {
        
        let manager = BLTNItemManager(rootItem: item)
        
        ThemeManager.default.apply(theme: Theme.self, to: manager) { themeable, theme in
            
            themeable.backgroundColor = theme.backgroundColor
            themeable.hidesHomeIndicator = false
            themeable.edgeSpacing = .compact
            
        }
        
        manager.backgroundViewStyle = .dimmed
        manager.statusBarAppearance = .hidden
        
        return manager
        
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
