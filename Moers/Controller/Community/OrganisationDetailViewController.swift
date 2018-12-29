//
//  OrganisationDetailViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 24.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class OrganisationDetailViewController: UIViewController {

    public var organisation: Organisation? { didSet { setupOrganisation(organisation) } }
    
    // MARK: - UI
    
    private lazy var scrollView = { ViewFactory.scrollView() }()
    private lazy var contentView = { ViewFactory.blankView() }()
    private lazy var headerView = { ViewFactory.organisationHeader() }()
    private lazy var seperator = { ViewFactory.blankView() }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTheming()
        self.setupConstraints()
        
    }
    
    // MARK: - Private Methods

    private func setupUI() {
        
        self.title = "Details"
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(headerView)
        self.contentView.addSubview(seperator)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.seperator.backgroundColor = theme.decentColor
            themeable.seperator.alpha = 0.5
            
        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [scrollView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 0),
                           scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           scrollView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: 0),
                           contentView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
                           contentView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
                           contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
                           contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
                           contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                           headerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
                           headerView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0),
                           headerView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0),
                           seperator.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
                           seperator.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
                           seperator.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16),
                           seperator.heightAnchor.constraint(equalToConstant: 1),
                           seperator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupOrganisation(_ organisation: Organisation?) {
        
        guard let organisation = organisation else { return }
        
        self.headerView.organisation = organisation
        
    }
    
}
