//
//  EntryValidationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 23.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI

class EntryValidationViewController: UIViewController {

    public var coordinator: DashboardCoordinator?
    
    private lazy var tableView = { ViewFactory.tableView() }()
    private var entries: [Entry] = []
    private let entryManager: EntryManagerProtocol
    
    init(otherCoordinator: OtherCoordinator) {
        self.entryManager = otherCoordinator.entryManager
        
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
                           tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func loadData() {
        
        entryManager.get { (result) in
            
            switch result {
                
            case .success(let entries):
                
                self.entries = entries.filter { !$0.isValidated }
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
}

extension EntryValidationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as? EntryValidationTableViewCell else { return UITableViewCell() }
        
        let entry = entries[indexPath.row]
        
        cell.titleLabel.text = entry.name
        cell.descriptionLabel.text = entry.createdAt?.format(format: "dd.MM.yyyy HH:mm")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension EntryValidationViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.decentColor
    }
    
}
