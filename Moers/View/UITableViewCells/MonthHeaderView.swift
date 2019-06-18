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

    lazy var titleLabel: UILabel = {
        
        var label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
        
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(titleLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
                           titleLabel.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0),
                           titleLabel.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -0),
                           titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -0)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.backgroundColor = theme.backgroundColor
            themeable.titleLabel.textColor = theme.color
            
        }
        
    }
    
}
