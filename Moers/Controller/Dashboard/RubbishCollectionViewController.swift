//
//  RubbishCollectionViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI

class RubbishCollectionViewController: UIViewController {

    private let identifier = "rubbishCollectionItem"
    private let headerIdentifier = "monthHeader"
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.register(RubbishCollectionItemTableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.register(MonthHeaderView.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        
        return tableView
        
    }()
    
    var sections: [Section] = []
    var items: [RubbishPickupItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("RubbishCollectionTitle")
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()
        self.loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.shared.logOpenedWasteSchedule()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [tableView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func loadData() {
        
        guard let street = RubbishManager.shared.rubbishStreet else {
            return
        }
        
        let pickupItems = RubbishManager.shared.loadRubbishPickupItems(for: street)
        
        pickupItems.observeNext { (items: [RubbishPickupItem]) in
            
            OperationQueue.main.addOperation {
                
                self.items = items
                self.buildSections()
                self.tableView.reloadData()
                
                UIAccessibility.post(notification: .layoutChanged, argument: nil)
                
            }
            
        }.dispose(in: self.bag)
        
        pickupItems.observeFailed { (error: Error) in
            print("Loading Rubbish Pickup Items failed: \(error.localizedDescription)")
        }.dispose(in: self.bag)
        
    }
    
    private func buildSections() {
        
        let mappedSections = items.map { (item: RubbishPickupItem) -> Section in
            
            let month = Date.component(.month, from: item.date)
            let year = Date.component(.year, from: item.date)
            
            return Section(month: month, year: year)
            
        }
        
        self.sections = Array(Set(mappedSections)).sorted { (lhs, rhs) -> Bool in
            
            if lhs.month != rhs.month {
                return lhs.month < rhs.month
            } else {
                return lhs.year < rhs.year
            }
            
        }
        
    }
    
    // MARK: - Data Handling
    
    private func items(for section: Section) -> [RubbishPickupItem] {
        
        return items.filter { (item: RubbishPickupItem) -> Bool in
            
            let month = Date.component(.month, from: item.date)
            let year = Date.component(.year, from: item.date)
            
            return month == section.month && year == section.year
            
        }
        
    }
    
}

extension RubbishCollectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension RubbishCollectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = sections[section]
        
        return items(for: section).count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! MonthHeaderView
        let section = sections[section]
        let date = Date.from("\(section.month) \(section.year)", withFormat: "M yyyy")?.format(format: "MMMM yyyy")
        
        headerView.titleLabel.text = date
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RubbishCollectionItemTableViewCell
        
        let section = sections[indexPath.section]
        cell.item = items(for: section)[indexPath.row]
        
        return cell
        
    }
    
}

extension RubbishCollectionViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
    }
    
}

extension RubbishCollectionViewController {
    
    struct Section: Equatable, Hashable {
        var month: Int
        var year: Int
    }
    
}
