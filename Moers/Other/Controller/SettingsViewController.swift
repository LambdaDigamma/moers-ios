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
import MMAPI
import MMUI
import Resolver
import RubbishFeature
import FuelFeature

class SettingsViewController: UIViewController {

    private let standardCellIdentifier = "standard"
    private let switchCellIdentifier = "switchCell"
    
    lazy var tableView = { ViewFactory.tableView(with: .grouped) }()
    lazy var manager = { makeManager(with: BLTNPageItem(title: "")) }()
    
    var data: [TableViewSection] = []
    
    @LazyInjected var rubbishService: RubbishService
    @LazyInjected var petrolService: PetrolService
    
    private let onboardingManager: OnboardingManager
    
    init() {
        
        self.onboardingManager = OnboardingManager()
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.reloadRows()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        title = String.localized("SettingsTitle")
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OtherTableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: switchCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    // MARK: - Settings Rows
    
    private func showThemes() {
        push(viewController: ThemeViewController.self)
    }
    
    private func showRubbishStreet() {
        
        let streetPage = onboardingManager.makeRubbishStreetPage()
        
        streetPage.actionHandler = { item in
            
            guard let item = item as? RubbishStreetPickerItem else { return }
            
            self.rubbishService.register(item.selectedStreet)
            
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
        
        let reminderPage = onboardingManager.makeRubbishReminderPage()
        
        reminderPage.alternativeButtonTitle = "Deaktivieren"
        reminderPage.actionHandler = { [weak self] item in
            
            guard let page = item as? RubbishReminderBulletinItem else { return }
            
            let hour = Calendar.current.component(.hour, from: page.picker.date)
            let minutes = Calendar.current.component(.minute, from: page.picker.date)
            
            self?.rubbishService.invalidateRubbishReminderNotifications()
            self?.rubbishService.registerNotifications(at: hour, minute: minutes)
            
            self?.reloadRows()
            
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
            
        }
        
        reminderPage.alternativeHandler = { [weak self] item in
            
            self?.rubbishService.disableReminder()
            self?.reloadRows()
            
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
            
        }
        
        self.manager.showBulletin(above: self)
        self.manager.push(item: reminderPage)
        
    }
    
    private func showPetrolType() {
        
        guard let petrolTypePage = onboardingManager.makePetrolType(preSelected: petrolService.petrolType) as? SelectorBulletinPage<FuelFeature.PetrolType> else { return }
        
        petrolTypePage.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
            item.manager?.popToRootItem()
            self.reload()
        }
        
        self.manager.showBulletin(above: self)
        self.manager.push(item: petrolTypePage)
        
    }
    
    private func showUserType() {
        
        guard let userTypePage = onboardingManager.makeUserTypePage(preSelected: UserManager.shared.user.type) as? SelectorBulletinPage<User.UserType> else { return }
        
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
        
        let hour = rubbishService.reminderHour
        let minute = rubbishService.reminderMinute
        
        var rubbishReminder: String
        
        if let hour = hour, let minute = minute, rubbishService.remindersEnabled {
            
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
        
        var sections: [TableViewSection] = []
        
//        sections.append(TableViewSection(title: String.localized("UIAdjustments"),
//                                rows: [NavigationRow(title: String.localized("ThemeTitle"), action: showThemes)]))
        
        sections.append(TableViewSection(title: String.localized("User"),
                                rows: [NavigationRow(title: String.localized("UserType") + ": " + User.UserType.localizedForCase(userType), action: showUserType)]))
        
        sections.append(TableViewSection(
            title: String.localized("Petrol"),
            rows: [
                NavigationRow(
                    title: String.localized("PetrolType") + ": " + petrolService.petrolType.name,
                    action: showPetrolType
                )
            ]
        ))
        
        if UserManager.shared.user.type == .citizen {
            
            sections.append(TableViewSection(
                title: String.localized("SettingsRubbishCollectionTitle"),
                rows: [
                    SwitchRow(
                        title: String.localized("Activated"),
                        switchOn: rubbishService.isEnabled,
                        action: triggerRubbishCollection
                    ),
                    NavigationRow(
                        title: String.localized("Street") + ": \(rubbishService.rubbishStreet?.displayName ?? "nicht ausgewählt")",
                        action: showRubbishStreet
                    ),
                    NavigationRow(
                        title: rubbishReminder,
                        action: showRubbishReminder
                    )
                ]
            ))
            
        }
        
        self.data = sections
        
        self.tableView.reloadData()
        
    }
    
    private func reload() {
        
        self.reloadRows()
        
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        
        tabBarController.updateDashboard()
        
    }
    
    private func triggerRubbishCollection(isEnabled: Bool) {
        
        rubbishService.isEnabled = isEnabled
        rubbishService.disableReminder()
        rubbishService.disableStreet()
        
        if isEnabled {
            self.showRubbishStreet()
        }
        
        self.reloadRows()
        
    }
    
    private func makeManager(with item: BLTNItem) -> BLTNItemManager {
        
        let manager = BLTNItemManager(rootItem: item)
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: manager)
        
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
            
            if let cell = cell as? OtherTableViewCell {
                MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: cell)
            }
            
        } else {
            
            let switchRow = data[indexPath.section].rows[indexPath.row] as? SwitchRow
            
            // swiftlint:disable:next force_cast
            let switchCell = tableView.dequeueReusableCell(withIdentifier: switchCellIdentifier) as! SwitchTableViewCell
            
            switchCell.descriptionLabel.text = switchRow?.title
            switchCell.switchControl.isOn = switchRow?.switchOn ?? false
            switchCell.action = switchRow?.action
            
            MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: switchCell)
            
            cell = switchCell
            
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow else { return }
        
        navigationRow.action?()
        
    }
    
}

extension SettingsViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.tableView.backgroundColor = UIColor.systemBackground // theme.backgroundColor
        self.tableView.separatorColor = UIColor.separator // theme.separatorColor
    }
    
}

extension BLTNItemManager: Themeable {
    
    public typealias Theme = ApplicationTheme
    
    public func apply(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        self.hidesHomeIndicator = false
        self.edgeSpacing = .compact
    }
    
}
