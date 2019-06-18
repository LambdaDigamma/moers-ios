//
//  AccountViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 24.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class AccountViewController: UIViewController {

    private let standardCellIdentifier = "standard"
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
        
    }()

    lazy var data: [Section] = {
        
        return [Section(title: "",
                        rows: [NavigationRow(title: "Abmelden", action: logout)])]
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Account"
        
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()
        
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
            themeable.tableView.backgroundColor = theme.backgroundColor
            themeable.tableView.separatorColor = theme.separatorColor
            
        }
        
    }

    // MARK: - Row Action
    
    private func logout() {
        
        var storedUser = UserManager.shared.user
        
        storedUser.id = nil
        storedUser.name = nil
        storedUser.description = nil
        
        UserManager.shared.register(storedUser)
        API.shared.token = nil
        API.shared.refreshToken = nil
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        var cell: UITableViewCell = UITableViewCell()
        
        if let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow {
            
            cell = tableView.dequeueReusableCell(withIdentifier: standardCellIdentifier)!
            
            cell.textLabel?.text = navigationRow.title
            
            cell.accessoryType = .disclosureIndicator
            
        }
        
        cell.selectionStyle = .none
        
        ThemeManager.default.apply(theme: Theme.self, to: cell) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.textLabel?.textColor = theme.color
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let accountRow = data[indexPath.section].rows[indexPath.row] as? AccountRow {
            
            accountRow.action?()
            
        } else if let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow {
            
            navigationRow.action?()
            
        }
        
    }
    
}
