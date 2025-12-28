//
//  OtherView.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class OtherView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: OtherViewModel
    private let dataSource: OtherDataSource
    
    public init(viewModel: OtherViewModel) {
        self.viewModel = viewModel
        self.dataSource = OtherDataSource(viewModel: viewModel)
        super.init(frame: .zero)
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var tableView = { ViewFactory.tableView(with: .grouped) }()
    
    private func setupUI() {
        
        self.addSubview(tableView)
        
        self.tableView.dataSource = dataSource
        self.tableView.register(UITableViewCell.self)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.tableView.separatorColor = UIColor.separator
        self.tableView.backgroundColor = UIColor.systemBackground
        
    }
    
    public func setTableViewDelegate(_ delegate: UITableViewDelegate) {
        self.tableView.delegate = delegate
    }
    
    public func update() {
        self.tableView.reloadData()
    }
    
}
