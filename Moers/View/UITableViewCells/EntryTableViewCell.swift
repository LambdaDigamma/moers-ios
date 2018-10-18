//
//  EntryTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 06.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class EntryTableViewCell: UITableViewCell {

    lazy var entryImageView: UIImageView = { ViewFactory.imageView() }()
    lazy var titleLabel: UILabel = { ViewFactory.label() }()
    lazy var subtitleLabel: UILabel = { ViewFactory.label() }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(entryImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [entryImageView.leftAnchor.constraint(equalTo: margins.leftAnchor),
                           entryImageView.topAnchor.constraint(equalTo: margins.topAnchor),
                           entryImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
                           entryImageView.widthAnchor.constraint(equalTo: entryImageView.heightAnchor),
                           titleLabel.topAnchor.constraint(equalTo: margins.topAnchor),
                           titleLabel.leftAnchor.constraint(equalTo: entryImageView.rightAnchor, constant: 8),
                           titleLabel.rightAnchor.constraint(equalTo: margins.rightAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.accessoryType = .disclosureIndicator
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            themeable.backgroundColor = theme.backgroundColor
            themeable.titleLabel.textColor = theme.color
            themeable.subtitleLabel.textColor = theme.decentColor
        }
        
        
    }
    
}
