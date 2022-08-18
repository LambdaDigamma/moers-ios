//
//  EntryHistoryViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 31.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import Gestalt

class EntryHistoryViewController: UIViewController {

    public var coordinator: MapCoordintor?
    
    public var entry: Entry?
    
    private let entryManager: EntryManagerProtocol
    private var audits: [Audit] = []
    private var tableView: UITableView = { CoreViewFactory.tableView() }()
    private let identifier = "auditCell"
    
    init(coordinator: MapCoordintor) {
        self.coordinator = coordinator
        self.entryManager = coordinator.entryManager
        super.init(nibName: nil, bundle: nil)
    }
    
    init(entryManager: EntryManagerProtocol) {
        self.entryManager = entryManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
        self.loadHistory()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = "Historie"
        
        self.view.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        self.tableView.register(AuditTableViewCell.self, forCellReuseIdentifier: identifier)
        
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

    private func loadHistory() {
        
        guard let entry = entry else { return }
        
        entryManager.fetchHistory(entry: entry) { (result) in
            
            switch result {
                
            case .success(let audits):
                
                DispatchQueue.main.async {
                    self.audits = audits.sorted(by: { (lhs, rhs) -> Bool in
                        return lhs.updatedAt ?? Date() > rhs.updatedAt ?? Date()
                    })
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
}

extension EntryHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AuditTableViewCell
        
        cell.audit = audits[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension EntryHistoryViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        
        if #available(iOS 13.0, *) {
            
            navigationController?.navigationBar.barTintColor = theme.navigationBarColor
            navigationController?.navigationBar.tintColor = theme.accentColor
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.accentColor]
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.accentColor]
            navigationController?.navigationBar.isTranslucent = true
            
            let appearance = UINavigationBarAppearance()
            
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = theme.navigationBarColor
            
            appearance.titleTextAttributes = [.foregroundColor : theme.accentColor]
            appearance.largeTitleTextAttributes = [.foregroundColor : theme.accentColor]
            
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.standardAppearance = appearance
            
        }
        
    }
    
}
