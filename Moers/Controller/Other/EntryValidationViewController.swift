//
//  EntryValidationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 23.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class EntryValidationViewController: UIViewController {

    private lazy var tableView = { ViewFactory.tableView() }()
    
    private var entries: [Entry] = []
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.loadData()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = "Einträge validieren"
        
        self.view.addSubview(tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(EntryValidationTableViewCell.self, forCellReuseIdentifier: "entryCell")
        
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
            themeable.tableView.separatorColor = theme.decentColor
            
        }
        
    }
    
    private func loadData() {
        
        EntryManager.shared.get { (error, entries) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let entries = entries else { return }
            
            self.entries = entries.filter { !$0.isValidated }
            
            self.tableView.reloadData()
            
        }
        
    }
    
}

extension EntryValidationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! EntryValidationTableViewCell
        
        cell.titleLabel.text = entries[indexPath.row].name
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
