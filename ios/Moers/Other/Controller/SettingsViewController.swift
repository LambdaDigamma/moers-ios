//
//  SettingsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import BLTNBoard
import Factory
import RubbishFeature
import FuelFeature

class SettingsViewController: UIViewController {

    private let onboardingManager = OnboardingManager()
    
    lazy var collectionView: UICollectionView = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    lazy var manager = { makeManager(with: BLTNPageItem(title: "")) }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    
    @LazyInjected(\.rubbishService) var rubbishService
    @LazyInjected(\.petrolService) var petrolService
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupDataSource()
        reloadRows()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UserActivity.current = UserActivities.configureSettings()
        
    }
    
    private func setupUI() {

        title = String(localized: "Settings")
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        let switchRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SwitchItem> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            
            let switchView = UISwitch()
            switchView.isOn = item.isOn
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            
            cell.accessories = [.customView(configuration: .init(customView: switchView, placement: .trailing()))]
        }
        
        let navigationRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NavigationItem> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .navigation(let navigationItem):
                return collectionView.dequeueConfiguredReusableCell(using: navigationRegistration, for: indexPath, item: navigationItem)
            case .switch(let switchItem):
                return collectionView.dequeueConfiguredReusableCell(using: switchRegistration, for: indexPath, item: switchItem)
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, string, indexPath in
            guard let self = self else { return }
            let section = self.dataSource?.sectionIdentifier(for: indexPath.section)
            var content = supplementaryView.defaultContentConfiguration()
            content.text = section?.title
            supplementaryView.contentConfiguration = content
            supplementaryView.backgroundConfiguration = .clear()
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
    }
    
    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupDataSource() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.user])
        snapshot.appendItems([.navigation(NavigationItem(title: "", action: nil))], toSection: .user)
        
        dataSource?.apply(snapshot, animatingDifferences: false)
        
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
            
            rubbishReminder = String(localized: "Reminder") + ": \(hourString):\(minuteString)"
            
        } else {
            rubbishReminder = String(localized: "Reminder") + ": " + String(localized: "not activated")
        }
        
        let userType = UserManager.shared.user.type
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        // User section
        snapshot.appendSections([.user])
        snapshot.appendItems(
            [
                .navigation(
                    NavigationItem(
                        title: String(localized: "Type") + ": " + userType.name,
                        action: showUserType
                    )
                )
            ],
            toSection: .user
        )

        // Petrol section
        snapshot.appendSections([.petrol])
        snapshot.appendItems(
            [
                .navigation(
                    NavigationItem(
                        title: String(localized: "Type") + ": " + petrolService.petrolType.name,
                        action: showPetrolType
                    )
                )
            ],
            toSection: .petrol
        )

        // Rubbish section (citizens only)
        if UserManager.shared.user.type == .citizen {

            snapshot.appendSections([.rubbish])

            let items: [Item] = [
                .switch(
                    SwitchItem(
                        title: String(localized: "Activated"),
                        isOn: rubbishService.isEnabled,
                        action: triggerRubbishCollection
                    )
                ),
                .navigation(
                    NavigationItem(
                        title: String(localized: "Street") + ": \(rubbishService.rubbishStreet?.displayName ?? String(localized: "NotSelected"))",
                        action: showRubbishStreet
                    )
                ),
                .navigation(
                    NavigationItem(
                        title: rubbishReminder,
                        action: showRubbishReminder
                    )
                )
            ]

            snapshot.appendItems(items, toSection: .rubbish)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true)
        
    }
    
    private func reload() {
        
        self.reloadRows()
        
        guard let splitViewController = self.splitViewController as? AppSplitViewController else { return }
        
        splitViewController.updateDashboard()
        
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
        
        manager.backgroundColor = UIColor.systemBackground
        manager.backgroundViewStyle = .dimmed
        manager.statusBarAppearance = .hidden
        manager.hidesHomeIndicator = false
        manager.edgeSpacing = .compact
        
        return manager
        
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let point = sender.convert(CGPoint.zero, to: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
        switch dataSource?.itemIdentifier(for: indexPath) {
        case .switch(let item):
            item.action?(sender.isOn)
        default:
            break
        }
    }
    
}

 extension SettingsViewController: UICollectionViewDelegate {
     
     func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
         guard let item = dataSource?.itemIdentifier(for: indexPath) else { return true }
         if case .switch = item {
             return false
         }
         return true
     }
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         collectionView.deselectItem(at: indexPath, animated: true)
         
         guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
         
         switch item {
         case .navigation(let navigationItem):
             navigationItem.action?()
         default:
             break
         }
     }
     
 }

enum Section: Hashable {
    case user
    case petrol
    case rubbish
    
    var title: String {
        switch self {
        case .user:
            return String.localized("User")
        case .petrol:
            return String.localized("Petrol")
        case .rubbish:
            return String.localized("SettingsRubbishCollectionTitle")
        }
    }
}

enum Item: Hashable {
    case navigation(NavigationItem)
    case `switch`(SwitchItem)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .navigation(let item):
            hasher.combine(item.title)
        case .switch(let item):
            hasher.combine(item.title)
            hasher.combine(item.isOn)
        }
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        switch (lhs, rhs) {
        case (.navigation(let lhsItem), .navigation(let rhsItem)):
            return lhsItem.title == rhsItem.title
        case (.switch(let lhsItem), .switch(let rhsItem)):
            return lhsItem.title == rhsItem.title && lhsItem.isOn == rhsItem.isOn
        default:
            return false
        }
    }
}

struct NavigationItem: Hashable {
    let title: String
    let action: (() -> Void)?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        return lhs.title == rhs.title
    }
}

struct SwitchItem: Hashable {
    let title: String
    let isOn: Bool
    let action: ((Bool) -> Void)?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(isOn)
    }
    
    static func == (lhs: SwitchItem, rhs: SwitchItem) -> Bool {
        return lhs.title == rhs.title && lhs.isOn == rhs.isOn
    }
}
