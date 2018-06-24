//
//  OtherViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class OtherViewController: UIViewController {

    private let standardCellIdentifier = "standard"
    private let accountCellIdentifier = "account"
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: accountCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        ThemeManager.default.apply(theme: Theme.self, to: tableView) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.separatorColor = theme.decentColor
        }
        
        return tableView
        
    }()
    
    lazy var data: [Section] = {
        
        return [Section(title: "",
                        rows: [AccountRow(title: "Account", action: showAccount)]),
                Section(title: String.localized("SettingsTitle"),
                        rows: [NavigationRow(title: String.localized("SettingsTitle"), action: showSettings)]),
                Section(title: String.localized("Legal"),
                        rows: [NavigationRow(title: String.localized("AboutTitle"), action: showAbout),
                               NavigationRow(title: String.localized("PrivacyPolicy"), action: showPrivacy),
                               NavigationRow(title: String.localized("Licences"), action: showLicences)])]
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [tableView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    // MARK: - Row Action
    
    private func showAccount() {
        
        if API.shared.token == nil {
            
            self.present(LoginViewController(), animated: true, completion: nil)
            
        } else {
            
            self.navigationController?.pushViewController(AccountViewController(), animated: true)
            
        }
        
    }
    
    private func showSettings() {
        push(viewController: SettingsViewController.self)
    }
    
    private func showAbout() {
        push(viewController: AboutViewController.self)
    }
    
    private func showPrivacy() {
        
        
        
    }
    
    private func showLicences() {
        push(viewController: LicensesViewController.self)
    }
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        
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
            
        } else {
            
            let _ = data[indexPath.section].rows[indexPath.row] as? AccountRow
            
            let accountCell = tableView.dequeueReusableCell(withIdentifier: accountCellIdentifier) as! AccountTableViewCell
            
            accountCell.update()
            
            cell = accountCell
            
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
