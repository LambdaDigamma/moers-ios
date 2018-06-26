//
//  RubbishCollectionViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class RubbishCollectionViewController: UIViewController {

    private let identifier = "rubbishCollectionItem"
    private let headerIdentifier = "monthHeader"
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        tableView.register(RubbishCollectionItemTableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.register(MonthHeaderView.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        
        return tableView
        
    }()
    
    var items: [RubbishCollectionItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("RubbishCollectionTitle")
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()
        self.loadData()
        
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
        
        RubbishManager.shared.loadItems(completion: { (items) in
            
            OperationQueue.main.addOperation {
                
                self.items = items
                self.tableView.reloadData()
                
            }
            
        })
        
    }
    
    // MARK: - Data Handling
    
    private var numberOfSections: Int {
        
        let set = Set(items.map { Date.component(.month, from: Date.from($0.date, withFormat: "dd.MM.yyyy") ?? Date()) })
        
        return set.count
        
    }
    
    private func items(for section: Int) -> [RubbishCollectionItem] {
        
        let currentMonth = Date.component(.month, from: Date())
        
        return items.filter { Date.component(.month, from: Date.from($0.date, withFormat: "dd.MM.yyyy")!) - currentMonth == section }
        
    }
    
}

extension RubbishCollectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension RubbishCollectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items(for: section).count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! MonthHeaderView
        
        let currentMonth = Date.component(.month, from: Date())
        
        let sectionMonth = currentMonth + section
        
        headerView.titleLabel.text = Date.from("\(sectionMonth)", withFormat: "M")?.format(format: "MMMM")
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RubbishCollectionItemTableViewCell
        
        cell.item = items(for: indexPath.section)[indexPath.row]
        
        return cell
        
    }
    
}
