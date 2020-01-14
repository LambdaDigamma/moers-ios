//
//  MonthHeaderView.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class MonthHeaderView: UITableViewHeaderFooterView {

    lazy var titleLabel = { ViewFactory.label() }()
    lazy var bgView: UIView = { ViewFactory.blankView() }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(bgView)
        self.contentView.addSubview(titleLabel)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [bgView.topAnchor.constraint(equalTo: self.topAnchor),
                           bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                           bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                           bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
                           titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0),
                           titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -0),
                           titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -0)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
}

extension MonthHeaderView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.bgView.backgroundColor = theme.backgroundColor.darker(by: 5)
        self.titleLabel.textColor = theme.color
    }
    
}
