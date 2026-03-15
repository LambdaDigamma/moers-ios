//
//  NewsTableViewCell.swift
//  moers festival
//
//  Created by Lennart Fischer on 28.01.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    lazy var titleLabel = ViewFactory.label()
    
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
        
        self.addSubview(titleLabel)
        
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 26)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        self.backgroundColor = UIColor.systemBackground
        self.titleLabel.textColor = UIColor.label
    }
    
}
