//
//  SearchResultTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class SearchResultTableViewCell: UITableViewCell {
    
    lazy var searchImageView: UIImageView = { ViewFactory.imageView() }()
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
        
    }()
    
    lazy var subtitleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        return label
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        self.contentView.addSubview(searchImageView)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [searchImageView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0),
                           searchImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
                           searchImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0),
                           searchImageView.widthAnchor.constraint(equalTo: searchImageView.heightAnchor),
                           titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
                           titleLabel.leftAnchor.constraint(equalTo: searchImageView.rightAnchor, constant: 8),
                           titleLabel.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: 0),
                           subtitleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0),
                           subtitleLabel.leftAnchor.constraint(equalTo: searchImageView.rightAnchor, constant: 8),
                           subtitleLabel.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: 0)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.accessoryType = .disclosureIndicator
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.titleLabel.textColor = theme.color
            themeable.subtitleLabel.textColor = theme.decentColor
        }
        
    }
    
}
