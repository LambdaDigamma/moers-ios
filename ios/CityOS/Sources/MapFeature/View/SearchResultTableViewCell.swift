//
//  SearchResultTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Core

class SearchResultTableViewCell: UITableViewCell {
    
    lazy var searchImageView = { CoreViewFactory.imageView() }()
    lazy var titleLabel = { CoreViewFactory.label() }()
    lazy var subtitleLabel = { CoreViewFactory.label() }()
    lazy var checkmarkView = { CoreViewFactory.checkmarkView() }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
        self.setupConstraints()
        self.applyTheming()
        
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
        
        let constraints = [
            searchImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0),
            searchImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
            searchImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0),
            searchImageView.widthAnchor.constraint(equalTo: searchImageView.heightAnchor),
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: searchImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            subtitleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0),
            subtitleLabel.leadingAnchor.constraint(equalTo: searchImageView.trailingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: checkmarkView.leadingAnchor, constant: -4),
            checkmarkView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            checkmarkView.heightAnchor.constraint(equalToConstant: 20),
            checkmarkView.widthAnchor.constraint(equalTo: checkmarkView.heightAnchor),
            checkmarkView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func applyTheming() {
        self.accessoryType = .disclosureIndicator
        self.backgroundColor = UIColor.systemBackground
        self.titleLabel.textColor = UIColor.label
        self.subtitleLabel.textColor = UIColor.secondaryLabel
    }
    
}
