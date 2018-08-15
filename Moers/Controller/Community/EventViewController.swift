//
//  EventViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import SafariServices

class EventViewController: UIViewController {

    lazy var tableView: UITableView = { ViewFactory.tableView() }()
    
    private var events: [Event] = []
    private let identifier = "event"
    private let headerIdentifier = "monthHeader"
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("Events")
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.loadData()
        
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        
        let queue = OperationQueue()
        
        queue.addOperation {
            
            EventManager.shared.getEvents(completion: { (error, events) in
                
                OperationQueue.main.addOperation {
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    guard let events = events else { return }
                    
                    self.events = events.filter { $0.parsedDate >= Date.yesterday }
                    self.tableView.reloadData()
                    
                }
                
            })
            
        }
        
    }
    
    private func openURL(_ url: URL) {
        
        let svc = SFSafariViewController(url: url)
        svc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
        svc.preferredControlTintColor = navigationController?.navigationBar.tintColor
        self.present(svc, animated: true, completion: nil)
        
    }
    
    private func setupUI() {
        
        self.view.addSubview(tableView)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 80
        
        self.tableView.register(EventTableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.register(MonthHeaderView.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        
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

    private var numberOfSections: Int {
        
        let set = Set(events.map { Date.component(.month, from: Date.from($0.date, withFormat: "dd.MM.yyyy") ?? Date()) })
        
        return set.count
        
    }
    
    private func events(for section: Int) -> [Event] {
        
        let currentMonth = Date.component(.month, from: Date())
        
        return events.filter { Date.component(.month, from: Date.from($0.date, withFormat: "dd.MM.yyyy")!) - currentMonth == section }
        
    }
    
}

extension EventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events(for: section).count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! EventTableViewCell
        
        cell.event = events(for: indexPath.section)[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! MonthHeaderView
        
        let currentMonth = Date.component(.month, from: Date())
        
        let sectionMonth = currentMonth + section
        
        headerView.titleLabel.text = Date.from("\(sectionMonth)", withFormat: "M")?.format(format: "MMMM")
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let eventURL = events(for: indexPath.section)[indexPath.row].url else { return }
        
        guard let url = URL(string: eventURL) else { return }
        
        openURL(url)
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
