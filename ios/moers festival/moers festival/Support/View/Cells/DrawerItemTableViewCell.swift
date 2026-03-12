//
//  DrawerItemTableViewCell.swift
//  moers festival
//
//  Created by Lennart Fischer on 25.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import UIKit

class DrawerItemTableViewCell: UITableViewCell {
    
    static var identifier = "DrawerItemTableViewCell"
    
    lazy var titleLabel = { ViewFactory.label() }()
    lazy var subtitleLabel = { ViewFactory.label() }()
    
    // MARK: - Inits
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = 0.5
        self.subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        self.subtitleLabel.numberOfLines = 0
        
        self.selectionStyle = .none
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
                           titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0),
                           titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0),
                           titleLabel.heightAnchor.constraint(equalToConstant: 22),
                           subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                           subtitleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0),
                           subtitleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0),
                           subtitleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.accessoryType = .disclosureIndicator
        
        self.backgroundColor = UIColor.systemBackground
        self.titleLabel.textColor = UIColor.label
        self.subtitleLabel.textColor = UIColor.secondaryLabel
        
    }
    
}
