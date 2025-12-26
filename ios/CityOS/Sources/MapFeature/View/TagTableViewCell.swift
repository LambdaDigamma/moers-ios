//
//  TagTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 12.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Core

class TagTableViewCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = { CoreViewFactory.label() }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(titleLabel)
        
        self.setupConstraints()
        self.applyTheming()
        
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [titleLabel.topAnchor.constraint(equalTo: margins.topAnchor),
                           titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                           titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                           titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func applyTheming() {
        self.accessoryType = .disclosureIndicator
        self.backgroundColor = UIColor.systemBackground
        self.titleLabel.textColor = UIColor.label
    }
    
}
