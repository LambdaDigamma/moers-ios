//
//  SettingsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class SettingsViewController: UIViewController {

    private let standardCellIdentifier = "standard"
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        ThemeManager.default.apply(theme: Theme.self, to: tableView) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.separatorColor = theme.decentColor
        }
        
        return tableView
        
    }()
    
    lazy var data: [Section] = {
        
        return [Section(title: "",
                        rows: [Row(title: String.localized("ThemeTitle"), action: showThemes)])]
        
    }()
    
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
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themable, theme) in
            
            themable.view.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
    private func showThemes() {
        push(viewController: ThemeViewController.self)
    }
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: standardCellIdentifier)!
        
        cell.textLabel?.text = data[indexPath.section].rows[indexPath.row].title
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        ThemeManager.default.apply(theme: Theme.self, to: cell) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.textLabel?.textColor = theme.color
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        data[indexPath.section].rows[indexPath.row].action?()
        
    }
    
}
