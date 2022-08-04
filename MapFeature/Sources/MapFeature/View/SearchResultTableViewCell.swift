//
//  SearchResultTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI
import Core

class SearchResultTableViewCell: UITableViewCell {
    
    lazy var searchImageView = { ViewFactory.imageView() }()
    lazy var titleLabel = { ViewFactory.label() }()
    lazy var subtitleLabel = { ViewFactory.label() }()
    lazy var checkmarkView = { ViewFactory.checkmarkView() }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        self.contentView.addSubview(searchImageView)
        self.contentView.addSubview(checkmarkView)
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = 0.5
        self.subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        self.checkmarkView.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [searchImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0),
                           searchImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
                           searchImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0),
                           searchImageView.widthAnchor.constraint(equalTo: searchImageView.heightAnchor),
                           titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
                           titleLabel.leadingAnchor.constraint(equalTo: searchImageView.trailingAnchor, constant: 8),
                           titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0),
                           subtitleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0),
                           subtitleLabel.leadingAnchor.constraint(equalTo: searchImageView.trailingAnchor, constant: 8),
                           subtitleLabel.trailingAnchor.constraint(equalTo: checkmarkView.leadingAnchor, constant: -4),
                           checkmarkView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                           checkmarkView.heightAnchor.constraint(equalToConstant: 20),
                           checkmarkView.widthAnchor.constraint(equalTo: checkmarkView.heightAnchor),
                           checkmarkView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.accessoryType = .disclosureIndicator
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
}

extension SearchResultTableViewCell: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        self.titleLabel.textColor = theme.color
        self.subtitleLabel.textColor = theme.decentColor
    }
    
}
