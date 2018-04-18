//
//  RebuildSearchResultTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class RebuildSearchResultTableViewCell: UITableViewCell {
    
    lazy var searchImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
        
    }()
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        
        return label
        
    }()
    
    lazy var subtitleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        label.textColor = UIColor.darkGray
        
        return label
        
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.titleLabel.textColor = theme.color
            themeable.subtitleLabel.textColor = theme.decentColor
        }
        
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(searchImageView)
        
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [searchImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           searchImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           searchImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
                           searchImageView.widthAnchor.constraint(equalTo: searchImageView.heightAnchor),
                           titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           titleLabel.leftAnchor.constraint(equalTo: searchImageView.rightAnchor, constant: 8),
                           titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
                           subtitleLabel.leftAnchor.constraint(equalTo: searchImageView.rightAnchor, constant: 8),
                           subtitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
