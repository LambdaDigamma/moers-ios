//
//  EntryValidationTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 24.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class EntryValidationTableViewCell: UITableViewCell {

    lazy var validationImageView = { ViewFactory.imageView() }()
    lazy var titleLabel = { ViewFactory.label() }()
    lazy var descriptionLabel = { ViewFactory.label() }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(validationImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [validationImageView.leftAnchor.constraint(equalTo: margins.leftAnchor),
                           validationImageView.topAnchor.constraint(equalTo: margins.topAnchor),
                           validationImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
                           validationImageView.widthAnchor.constraint(equalTo: validationImageView.heightAnchor),
                           titleLabel.topAnchor.constraint(equalTo: margins.topAnchor),
                           titleLabel.leftAnchor.constraint(equalTo: validationImageView.rightAnchor, constant: 8),
                           titleLabel.rightAnchor.constraint(equalTo: margins.rightAnchor),
                           descriptionLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
                           descriptionLabel.leftAnchor.constraint(equalTo: validationImageView.rightAnchor, constant: 8),
                           descriptionLabel.rightAnchor.constraint(equalTo: margins.rightAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.accessoryType = .disclosureIndicator
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            themeable.backgroundColor = theme.backgroundColor
            themeable.titleLabel.textColor = theme.color
            themeable.descriptionLabel.textColor = theme.decentColor
        }
        
    }
    
}