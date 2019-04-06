//
//  OrganisationsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 25.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI

class OrganisationsViewController: UIViewController {

    var organisations: [Organisation] = []
    
    // MARK: - UI
    
    private lazy var tableView = { ViewFactory.tableView() }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.organisations = [Organisation(id: 1, name: "Code for Niederrhein", description: "Das ist eine kurze Beschreibung", entryID: nil, iconURL: URL(string: "https://www.codeforniederrhein.de/wp-content/uploads/2017/01/cfn_logo_521.png")),
                              Organisation(id: 2, name: "moers festival", description: "Das ist eine kurze Beschreibung", entryID: nil, iconURL: URL(string: "http://www.moers-festival.de/fileadmin/img/logo-quer_md.gif")),
                              Organisation(id: 3, name: "Gymnasium Adolfinum", description: "Das ist eine kurze Beschreibung", entryID: nil, iconURL: nil),
                              Organisation(id: 4, name: "Schlosstheater Moers", description: "Das ist eine kurze Beschreibung", entryID: nil, iconURL: nil)]
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = "Organisationen"
        
        self.view.addSubview(tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(OrganisationTableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    private func setupConstraints() {
        
        let constraints = [tableView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.safeLeftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.safeRightAnchor),
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
    
}

extension OrganisationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organisations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrganisationTableViewCell
        
        cell.organisation = organisations[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailViewController = OrganisationDetailViewController()
        
        detailViewController.organisation = organisations[indexPath.row]
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? OrganisationTableViewCell else { return }
        
        cell.backgroundColor = cell.backgroundColor?.darker(by: 10)
        
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? OrganisationTableViewCell else { return }
        
        cell.backgroundColor = cell.backgroundColor?.lighter(by: 10)
        
    }
    
}
