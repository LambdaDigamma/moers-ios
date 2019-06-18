//
//  TagTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 12.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class TagTableViewCell: UITableViewCell {

    lazy var titleLabel: UILabel = { ViewFactory.label() }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(titleLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [titleLabel.topAnchor.constraint(equalTo: margins.topAnchor),
                           titleLabel.leftAnchor.constraint(equalTo: margins.leftAnchor),
                           titleLabel.rightAnchor.constraint(equalTo: margins.rightAnchor),
                           titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.accessoryType = .disclosureIndicator
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.titleLabel.textColor = theme.color
        }
        
    }
    
}
