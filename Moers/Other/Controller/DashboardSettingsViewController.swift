//
//  DashboardSettingsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI


@available(iOS 13.0, *)
class DashboardSettingsViewController: UIViewController {

    private lazy var tableView: UITableView = { ViewFactory.tableView(with: .insetGrouped) }()
    
    var dataSource: SettingsDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.populateDataSource()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.title = "Anpassen"
        self.view.addSubview(tableView)
        
        self.tableView.delegate = self
        self.tableView.setEditing(true, animated: false)
        self.tableView.isEditing = true
        self.tableView.register(UITableViewCell.self)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            tableView.topAnchor.constraint(equalTo: self.safeTopAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.safeLeftAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.safeRightAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func populateDataSource() {
        
        dataSource = SettingsDataSource(tableView: tableView, cellProvider: { (tableView: UITableView, indexPath: IndexPath, item: DashboardItem) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            
            cell.textLabel?.text = item.name
            cell.showsReorderControl = true
            cell.backgroundColor = UIColor.darkGray
            
            return cell
            
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, DashboardItem>()
        snapshot.appendSections([.active, .inactive])
        snapshot.appendItems([DashboardItem(name: "Test1"), DashboardItem(name: "Test2")], toSection: .active)
        snapshot.appendItems([DashboardItem(name: "Test3"), DashboardItem(name: "Test4")], toSection: .inactive)
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }

    enum Section: CaseIterable {
        case active
        case inactive
    }
    
}

@available(iOS 13.0, *)
extension DashboardSettingsViewController {
    
    class SettingsDataSource: UITableViewDiffableDataSource<Section, DashboardItem> {
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            if section == 0 {
                return "Aktiv"
            } else {
                return "Inaktiv"
            }
            
        }
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//            let itemToMove = numbers[sourceIndexPath.row]
//            numbers.remove(at: sourceIndexPath.row)
//            numbers.insert(itemToMove, at: destinationIndexPath.row)
        }
        
    }
    
}

@available(iOS 13.0, *)
extension DashboardSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if indexPath.section == 0 {
            return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.insert
        }
        
    }
    
}

@available(iOS 13.0, *)
extension DashboardSettingsViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
    }
    
}
