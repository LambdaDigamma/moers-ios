//
//  MonthHeaderView.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class MonthHeaderView: UITableViewHeaderFooterView {

    lazy var titleLabel: UILabel = {
        
        var label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
        
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.addSubview(titleLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.backgroundColor = theme.backgroundColor
            themeable.titleLabel.textColor = theme.color
            
        }
        
    }
    
}
