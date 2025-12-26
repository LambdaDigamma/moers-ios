//
//  EntryValidationTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 24.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Core

public class EntryValidationTableViewCell: UITableViewCell {

    public lazy var validationImageView = { CoreViewFactory.imageView() }()
    public lazy var titleLabel = { CoreViewFactory.label() }()
    public lazy var descriptionLabel = { CoreViewFactory.label() }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(validationImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)
        
        self.setupUI()
        self.setupConstraints()
        self.applyTheming()
        
        self.selectionStyle = .none
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints: [NSLayoutConstraint] = [
            validationImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            validationImageView.topAnchor.constraint(equalTo: margins.topAnchor),
            validationImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            validationImageView.widthAnchor.constraint(equalTo: validationImageView.heightAnchor),
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: validationImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: validationImageView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func applyTheming() {
        self.accessoryType = .disclosureIndicator
        self.backgroundColor = UIColor.systemBackground
        self.titleLabel.textColor = UIColor.label
        self.descriptionLabel.textColor = UIColor.secondaryLabel
    }
    
}
